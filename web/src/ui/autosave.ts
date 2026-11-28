// Work in progress kept in the browser, so a closed tab or a crash loses
// nothing: a second after each change, while the document is not saved, the
// engine's copy of it (the app's snapshot: named texts, as a pattern and its
// measurement set, or a layout and the files its sources read) is written
// to the page's private file system (OPFS) under the tab's own id, with a
// record in IndexedDB of the app, when, the file name, and the handles of
// the files it came from, so a document opened again still saves to its
// file. Saving removes it. Each tab holds a Web Lock while it is open, so
// work whose lock is free is left over from a tab that closed, which the app
// offers to open again. The apps share the site, so each
// sees only its own. Where the page cannot write OPFS files the texts go in
// the record. Nothing leaves the machine.
import { EngineError } from '../engine/engine.ts';
import { isRecord } from '../engine/replies.ts';
import { allRecords, deleteRecord, putRecord, WORK_STORE } from './browserStore.ts';

const WORK_FOLDER = 'work';
// How long after a change the work is kept, in ms, so a run of edits is written once
const DELAY_MS = 1000;
const LOCK_PREFIX = 'opensloper-work-';
// The engine's code for a call it refuses, as while a drag is open (RPC_REFUSED)
const REFUSED = -32000;

// What Autosave needs of the app's document
export interface AutosaveDocument {
  readonly state: { readonly modified: boolean };
  addListener(listener: () => void): void;
}

// What the app knows of the document besides its texts
export interface WorkFiles {
  fileName: string;
  // The files it came from, by the app's own names for them, so it still saves to them
  handles: Record<string, FileSystemFileHandle | undefined>;
}

// A tab's work as kept: its texts are read with Autosave.texts
export interface Work extends WorkFiles {
  id: string;
  // The app that kept it, as design or publish
  app: string;
  // When it was kept, in ms since 1970
  time: number;
  // The texts' names; each is kept in a file named by its place here, as a
  // name may be a path
  names: string[];
  // The texts, here only where OPFS files cannot be written
  texts?: string[];
}

// The texts by name, as the snapshot gave them
export type WorkTexts = Map<string, string>;

function isWork(value: unknown): value is Work {
  return (
    isRecord(value) &&
    typeof value.id === 'string' &&
    typeof value.app === 'string' &&
    typeof value.time === 'number' &&
    Array.isArray(value.names)
  );
}

// OPFS files written from the page, which some browsers allow only in workers
function canWriteFiles(): boolean {
  return (
    typeof navigator.storage.getDirectory === 'function' &&
    typeof FileSystemFileHandle.prototype.createWritable === 'function'
  );
}

async function workFolder(id: string, create: boolean): Promise<FileSystemDirectoryHandle> {
  const root = await navigator.storage.getDirectory();
  const work = await root.getDirectoryHandle(WORK_FOLDER, { create });
  return work.getDirectoryHandle(id, { create });
}

async function writeFile(folder: FileSystemDirectoryHandle, name: string, text: string): Promise<void> {
  const stream = await (await folder.getFileHandle(name, { create: true })).createWritable();
  await stream.write(text);
  await stream.close();
}

async function readFile(folder: FileSystemDirectoryHandle, name: string): Promise<string> {
  return (await (await folder.getFileHandle(name)).getFile()).text();
}

// True when no open tab holds the work's lock; without Web Locks, every
// other tab's work counts as left over
async function lockFree(id: string): Promise<boolean> {
  if (typeof navigator.locks === 'undefined') {
    return true;
  }
  return navigator.locks.request(LOCK_PREFIX + id, { ifAvailable: true }, (lock) => lock !== null);
}

export class Autosave {
  private readonly id = crypto.randomUUID();
  private readonly app: string;
  private readonly document: AutosaveDocument;
  private readonly snapshot: () => Promise<WorkTexts | undefined>;
  private readonly files: () => WorkFiles;
  private readonly kept: (kept: boolean) => void;
  private timer: ReturnType<typeof setTimeout> | undefined;
  // One write or removal at a time, in order
  private queue: Promise<void> = Promise.resolve();
  private hasWork = false;
  // Writes waiting or under way, which a save must follow with a removal
  private writes = 0;

  // App names the app; snapshot gives the document's texts from the engine
  // or undefined if the document was replaced while it was being read;
  // files says what the app knows of the document's files; kept hears when
  // the tab's work is written or removed
  constructor(
    app: string,
    document: AutosaveDocument,
    snapshot: () => Promise<WorkTexts | undefined>,
    files: () => WorkFiles,
    kept: (kept: boolean) => void,
  ) {
    this.app = app;
    this.document = document;
    this.snapshot = snapshot;
    this.files = files;
    this.kept = kept;
  }

  // Holds the tab's lock and keeps its work from now on
  start(): void {
    if (typeof navigator.locks !== 'undefined') {
      // Held until the tab closes
      void navigator.locks.request(LOCK_PREFIX + this.id, async () => new Promise<void>(() => undefined));
    }
    this.document.addListener(() => {
      this.changed();
    });
    window.addEventListener('pagehide', () => {
      if (this.timer !== undefined) {
        void this.flush();
      }
    });
  }

  // Work left by tabs that have closed, the newest first
  async leftOver(): Promise<Work[]> {
    let records: unknown[];
    try {
      records = await allRecords(WORK_STORE);
    } catch {
      return [];
    }
    const others = records.filter(isWork).filter((work) => work.app === this.app && work.id !== this.id);
    const free = await Promise.all(others.map(async (work) => lockFree(work.id)));
    // A new array from filter, so sorting it in place changes nothing else
    // oxlint-disable-next-line unicorn/no-array-sort
    return others.filter((_work, index) => free[index] === true).sort((one, other) => other.time - one.time);
  }

  async texts(work: Work): Promise<WorkTexts> {
    const kept = work.texts;
    if (kept !== undefined) {
      return new Map(work.names.map((name, index) => [name, kept[index] ?? '']));
    }
    const folder = await workFolder(work.id, false);
    const texts = await Promise.all(work.names.map(async (_name, index) => readFile(folder, String(index))));
    return new Map(work.names.map((name, index) => [name, texts[index] ?? '']));
  }

  // Removes work left over, once opened again or dropped
  async discard(work: Work): Promise<void> {
    await this.removeWork(work.id);
  }

  // Writes the work now, as the tab closes, rather than after the delay;
  // resolves once it is written
  async flush(): Promise<void> {
    if (this.timer !== undefined) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }
    this.enqueueWrite();
    await this.queue;
  }

  private changed(): void {
    const waited = this.timer !== undefined;
    if (this.timer !== undefined) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }
    if (!this.document.state.modified) {
      // Saved, or nothing done: nothing to lose, once any write under way has finished
      if (this.hasWork || waited || this.writes > 0) {
        this.enqueue(async () => this.removeOwn());
      }
      return;
    }
    this.timer = setTimeout(() => {
      this.timer = undefined;
      this.enqueueWrite();
    }, DELAY_MS);
  }

  private enqueueWrite(): void {
    this.writes++;
    this.enqueue(async () => {
      try {
        await this.keep();
      } finally {
        this.writes--;
      }
    });
  }

  private enqueue(job: () => Promise<void>): void {
    this.queue = this.queue.then(job).catch((error: unknown) => {
      // Storage full or closed to the page: the work is only in the tab
      console.warn('work in progress not kept', error);
    });
  }

  private async keep(): Promise<void> {
    if (!this.document.state.modified) {
      return;
    }
    let texts: WorkTexts | undefined;
    try {
      texts = await this.snapshot();
    } catch (error: unknown) {
      // A drag is open: kept once it ends, which changes the document
      if (error instanceof EngineError && error.code === REFUSED) {
        return;
      }
      throw error;
    }
    if (texts === undefined) {
      return;
    }
    const names = [...texts.keys()];
    const work: Work = {
      id: this.id,
      app: this.app,
      time: Date.now(),
      names,
      ...this.files(),
    };
    if (canWriteFiles()) {
      const folder = await workFolder(this.id, true);
      for (const [index, text] of [...texts.values()].entries()) {
        // One file after another, in their folder
        // oxlint-disable-next-line no-await-in-loop
        await writeFile(folder, String(index), text);
      }
    } else {
      work.texts = [...texts.values()];
    }
    await putRecord(WORK_STORE, work, this.id);
    this.hasWork = true;
    this.kept(true);
  }

  private async removeOwn(): Promise<void> {
    // Changed again while waiting its turn
    if (this.document.state.modified) {
      return;
    }
    await this.removeWork(this.id);
    this.hasWork = false;
    this.kept(false);
  }

  private async removeWork(id: string): Promise<void> {
    await deleteRecord(WORK_STORE, id);
    if (canWriteFiles()) {
      try {
        const root = await navigator.storage.getDirectory();
        await (await root.getDirectoryHandle(WORK_FOLDER)).removeEntry(id, { recursive: true });
      } catch {
        // Never written, or kept in the record
      }
    }
  }
}
