// The web Measurements app, as Sloper.Measurements.MainForm: starts the engine
// and opens a measurement set or size table. Its table is edited in the grid,
// with Add, Delete, Up and Down over it, then the size buttons, which act on
// the size whose column the chosen cell is in, and Undo and Redo on the
// toolbar; each change is one undo step. Name and Notes are above the
// table, each committed when Enter is pressed or the field is left, Show in
// chooses the unit of its values, and the status bar has a message. Beside
// the table, the body figure shows where the set's measurements are taken,
// and Add From the Catalogue lists the measurements the set lacks, with the
// details of the one chosen or of the table's row. Check Against Pattern
// lists, under the table, what a pattern needs that the set cannot give it.
// Examples… opens one of the user guide's measurement files. Import… reads
// a Seamly2D or Valentina file as a new set, and Export… downloads the set
// as one.
// Nothing leaves the machine: the files are read in the browser and given to
// the engine as text.
import {
  MeasurementDocument,
  type ImportReport,
  type MissingMeasurement,
  type SeamlyKind,
} from '../document/measurementDocument.ts';
import { MEASURE_UNITS, type MeasureUnit } from '../editor/rulerTicks.ts';
import { Engine, EngineError } from '../engine/engine.ts';
import { recordsField, stringField } from '../engine/replies.ts';
import { Autosave, type Work, type WorkFiles } from '../ui/autosave.ts';
import { baseName, downloadText } from '../ui/download.ts';
import { fetchExampleFile } from '../ui/examples.ts';
import { FileAccess, MEASUREMENTS_EXTENSION } from '../ui/fileAccess.ts';
import { keepOffline } from '../ui/offline.ts';
import { matchesShortcut, parseShortcut, shortcutText } from '../ui/shortcuts.ts';
import { STRINGS } from '../ui/strings.ts';
import { BodyFigure } from './bodyFigure.ts';
import { CatalogueBrowser } from './catalogueBrowser.ts';
import { MEASUREMENT_EXAMPLES } from './examples.ts';
import { MeasurementGrid } from './measurementGrid.ts';
import { PatternCheck } from './patternCheck.ts';
import { ExportDialog, ReportDialog } from './seamlyDialogs.ts';

const PATTERN_EXTENSION = '.sloper';
// The Seamly2D and Valentina files Import reads, as the desktop's filter
const SEAMLY_EXTENSIONS = new Set(['.smis', '.smms', '.vit', '.vst']);
const WORK_SET = 'set';
const WORK_DISK_TEXT = 'disk';

function element<T extends HTMLElement>(id: string, type: new () => T): T {
  const found = document.getElementById(id);
  if (!(found instanceof type)) {
    throw new Error(`the page has no #${id}`);
  }
  return found;
}

const toolbar = element('toolbar', HTMLElement);
const message = element('message', HTMLElement);
const openInput = element('open-input', HTMLInputElement);
const importInput = element('import-input', HTMLInputElement);
const patternInput = element('pattern-input', HTMLInputElement);
const left = element('left', HTMLElement);
const nameBox = element('set-name', HTMLInputElement);
const notesBox = element('set-notes', HTMLInputElement);
const showIn = element('show-in', HTMLSelectElement);
const table = element('table', HTMLElement);
const empty = element('empty', HTMLElement);
const tableButtons = element('table-buttons', HTMLElement);
const side = element('side', HTMLElement);

function showMessage(text: string): void {
  message.textContent = text;
}

function showFailure(error: unknown): void {
  showMessage(STRINGS.failed(error instanceof Error ? error.message : String(error)));
  console.error(error);
}

function plainButton(caption: string, hint: string, action: () => void): HTMLButtonElement {
  const button = document.createElement('button');
  button.type = 'button';
  button.textContent = caption;
  button.title = hint;
  button.addEventListener('click', action);
  return button;
}

function iconButton(icon: string, caption: string, hint: string, action: () => void): HTMLButtonElement {
  const button = document.createElement('button');
  button.type = 'button';
  button.title = hint;
  const image = document.createElement('img');
  image.src = `icons/${icon}.svg`;
  image.alt = '';
  const label = document.createElement('span');
  label.textContent = caption;
  button.append(image, label);
  button.addEventListener('click', action);
  return button;
}

class MeasurementsApp {
  private readonly document: MeasurementDocument;
  private readonly files = FileAccess.create();
  private readonly autosave: Autosave;
  private fileHandle: FileSystemFileHandle | undefined;
  private diskText: string | undefined;
  private fileBusy = false;
  private workKept = false;
  private readonly grid: MeasurementGrid;
  private readonly catalogue: CatalogueBrowser;
  private readonly figure: BodyFigure;
  private readonly patternCheck: PatternCheck;
  private readonly checkButton: HTMLButtonElement;
  private readonly stopCheckButton: HTMLButtonElement;
  // The entry the catalogue shows, and the table's row under the pointer,
  // which the figure highlights over it, as on the desktop
  private shownKey = '';
  private gridHover = '';
  private readonly undoButton: HTMLButtonElement;
  private readonly redoButton: HTMLButtonElement;
  private readonly saveButton: HTMLButtonElement;
  private readonly saveAsButton: HTMLButtonElement;
  private readonly importButton: HTMLButtonElement;
  private readonly exportButton: HTMLButtonElement;
  private readonly exportDialog = new ExportDialog(showFailure);
  private readonly reportDialog = new ReportDialog();
  private readonly addButton: HTMLButtonElement;
  private readonly deleteButton: HTMLButtonElement;
  private readonly upButton: HTMLButtonElement;
  private readonly downButton: HTMLButtonElement;
  private readonly sizeButtons: HTMLElement;
  // The set whose name and notes the fields show
  private shownGeneration = -1;
  private shownName = '';
  private shownNotes = '';
  private readonly addSizeButton: HTMLButtonElement;
  private readonly renameSizeButton: HTMLButtonElement;
  private readonly deleteSizeButton: HTMLButtonElement;
  private readonly sizeLeftButton: HTMLButtonElement;
  private readonly sizeRightButton: HTMLButtonElement;

  constructor(
    engine: Engine,
    private readonly shortcuts: ReadonlyMap<string, string>,
  ) {
    this.document = new MeasurementDocument(engine);
    // The file name, handle and on-disk baseline travel with the same snapshot.
    let snapshotFiles: WorkFiles = { fileName: '', handles: {} };
    this.autosave = new Autosave(
      'measurements',
      this.document,
      async () => {
        const generation = this.document.generation;
        const fileName = this.document.fileName;
        const handle = this.fileHandle;
        const diskText = this.diskText;
        const text = await this.document.text();
        if (generation !== this.document.generation || handle !== this.fileHandle || diskText !== this.diskText) {
          return undefined;
        }
        snapshotFiles = { fileName, handles: { [WORK_SET]: handle } };
        const texts = new Map([[WORK_SET, text]]);
        if (diskText !== undefined) {
          texts.set(WORK_DISK_TEXT, diskText);
        }
        return texts;
      },
      () => snapshotFiles,
      (kept) => {
        this.workKept = kept;
        document.body.dataset.workKept = String(kept);
      },
    );
    this.grid = new MeasurementGrid(this.document, {
      select: () => {
        this.refreshButtons();
        this.catalogue.showTableKey(this.grid.chosenKey);
      },
      zoom: () => undefined,
      delete: () => {
        this.run(this.deleteChosen());
      },
      column: () => {
        this.refreshButtons();
      },
      message: showMessage,
      failed: showFailure,
    });
    this.catalogue = new CatalogueBrowser(this.document, {
      added: (key) => {
        this.run(this.grid.chooseValue(key));
      },
      shown: (key) => {
        this.shownKey = key;
        this.showHighlight();
      },
      message: showMessage,
      failed: showFailure,
    });
    this.figure = new BodyFigure(this.document, {
      hover: (key) => {
        this.catalogue.showHover(key === '' ? undefined : key);
      },
      pick: (key) => {
        this.run(this.grid.chooseValue(key));
      },
      failed: showFailure,
    });
    this.patternCheck = new PatternCheck(this.document, {
      chosen: (key) => {
        this.catalogue.showTableKey(key);
      },
      fix: (item) => {
        this.run(this.fixMissing(item));
      },
    });
    this.checkButton = iconButton('file-search', STRINGS.checkPattern, STRINGS.checkPatternHint, () => {
      patternInput.click();
    });
    this.stopCheckButton = iconButton('player-stop', STRINGS.stopCheck, STRINGS.stopCheckHint, () => {
      this.run(this.document.stopCheck());
    });
    this.undoButton = iconButton('arrow-back-up', STRINGS.undo, STRINGS.undoHint, () => {
      this.run(this.document.undo());
    });
    this.redoButton = iconButton('arrow-forward-up', STRINGS.redo, STRINGS.redoHint, () => {
      this.run(this.document.redo());
    });
    const saveHint = this.files === undefined ? STRINGS.measureSaveHint : STRINGS.measureSaveToFileHint;
    this.saveButton = iconButton('device-floppy', STRINGS.save, this.shortcutHint('save', saveHint), () => {
      this.run(this.save(false));
    });
    this.saveAsButton = iconButton(
      'file-pencil',
      STRINGS.saveAs,
      this.shortcutHint('saveAs', STRINGS.measureSaveAsHint),
      () => {
        this.run(this.save(true));
      },
    );
    this.importButton = iconButton(
      'file-import',
      STRINGS.seamlyImport,
      this.shortcutHint('import', STRINGS.seamlyImportHint),
      () => {
        if (!this.fileBusy) {
          importInput.click();
        }
      },
    );
    this.exportButton = iconButton(
      'file-export',
      STRINGS.seamlyExportMenu,
      this.shortcutHint('exportMeasurements', STRINGS.seamlyExportHint),
      () => {
        this.run(this.chooseExport());
      },
    );
    this.addButton = plainButton(STRINGS.measureAdd, STRINGS.measureAddHint, () => {
      this.run(this.addMeasurement());
    });
    this.deleteButton = plainButton(STRINGS.measureDelete, STRINGS.measureDeleteHint, () => {
      this.run(this.deleteChosen());
    });
    this.upButton = plainButton(STRINGS.measureUp, STRINGS.measureUpHint, () => {
      this.run(this.moveChosen(-1));
    });
    this.downButton = plainButton(STRINGS.measureDown, STRINGS.measureDownHint, () => {
      this.run(this.moveChosen(1));
    });
    this.renameSizeButton = plainButton(STRINGS.measureRenameSize, STRINGS.measureRenameSizeHint, () => {
      this.run(this.renameSize());
    });
    this.deleteSizeButton = plainButton(STRINGS.measureDeleteSize, STRINGS.measureDeleteSizeHint, () => {
      this.run(this.deleteSize());
    });
    this.sizeLeftButton = plainButton(STRINGS.measureSizeLeft, STRINGS.measureSizeLeftHint, () => {
      this.run(this.moveSize(-1));
    });
    this.sizeRightButton = plainButton(STRINGS.measureSizeRight, STRINGS.measureSizeRightHint, () => {
      this.run(this.moveSize(1));
    });
    // Apart from the measurement buttons, as the desktop's three gaps
    this.sizeButtons = document.createElement('div');
    this.sizeButtons.className = 'size-buttons';
    this.addSizeButton = plainButton(STRINGS.measureAddSize, STRINGS.measureAddSizeHint, () => {
      this.run(this.addSize());
    });
    this.sizeButtons.append(
      this.addSizeButton,
      this.renameSizeButton,
      this.deleteSizeButton,
      this.sizeLeftButton,
      this.sizeRightButton,
    );
  }

  start(): void {
    element('set-name-label', HTMLElement).textContent = STRINGS.measureSetName;
    element('set-notes-label', HTMLElement).textContent = STRINGS.measureNotes;
    element('show-in-label', HTMLElement).textContent = STRINGS.measureShowIn;
    empty.textContent = STRINGS.measureEmpty;
    const divider = document.createElement('span');
    divider.className = 'divider';
    const openButton = iconButton(
      'folder-open',
      STRINGS.open,
      this.shortcutHint('open', STRINGS.measureOpenHint),
      () => {
        this.run(this.chooseOpen());
      },
    );
    toolbar.append(openButton, this.exampleBox(), this.saveButton);
    if (this.files !== undefined) {
      toolbar.append(this.saveAsButton);
    }
    const secondDivider = document.createElement('span');
    secondDivider.className = 'divider';
    const thirdDivider = document.createElement('span');
    thirdDivider.className = 'divider';
    // In the desktop's order
    toolbar.append(
      divider,
      this.undoButton,
      this.redoButton,
      secondDivider,
      this.importButton,
      this.exportButton,
      thirdDivider,
      this.checkButton,
      this.stopCheckButton,
    );
    // Capture file shortcuts before the editable grid handles its own keys.
    const buttons = {
      open: openButton,
      save: this.saveButton,
      saveAs: this.saveAsButton,
      import: this.importButton,
      exportMeasurements: this.exportButton,
      undo: this.undoButton,
      redo: this.redoButton,
    };
    window.addEventListener('keydown', (event) => this.keyDown(event, buttons), true);
    left.append(this.patternCheck.element);
    patternInput.addEventListener('change', () => {
      const file = patternInput.files?.[0];
      patternInput.value = '';
      if (file !== undefined) {
        this.run(this.checkPattern(file));
      }
    });
    for (const box of [nameBox, notesBox]) {
      // Enter, or leaving the field, commits it, as the desktop's EditingDone
      box.addEventListener('change', () => {
        this.run(this.commitHeader());
      });
      box.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
          box.value = box === nameBox ? this.document.state.name : this.document.state.notes;
        }
      });
    }
    tableButtons.append(this.addButton, this.deleteButton, this.upButton, this.downButton, this.sizeButtons);
    openInput.addEventListener('change', () => {
      const file = openInput.files?.[0];
      openInput.value = '';
      if (file !== undefined) {
        this.run(this.openFile(file));
      }
    });
    importInput.addEventListener('change', () => {
      const file = importInput.files?.[0];
      importInput.value = '';
      if (file !== undefined) {
        this.run(this.importFile(file));
      }
    });
    for (const unit of MEASURE_UNITS) {
      showIn.add(new Option(unit, unit, unit === this.document.unit, unit === this.document.unit));
    }
    showIn.addEventListener('change', () => {
      const unit = MEASURE_UNITS.find((each) => each === showIn.value);
      if (unit !== undefined) {
        this.run(this.showIn(unit));
      }
    });
    side.append(this.figure.element, this.catalogue.element);
    this.grid.element.addEventListener('mouseover', (event) => {
      const row = event.target instanceof Element ? event.target.closest('tr') : null;
      this.gridHover = row?.dataset.key ?? '';
      this.showHighlight();
    });
    this.grid.element.addEventListener('mouseleave', () => {
      this.gridHover = '';
      this.showHighlight();
    });
    this.document.addListener(() => {
      this.showState();
    });
    this.showState();
    this.autosave.start();
    window.addEventListener('beforeunload', (event) => {
      if (this.document.state.modified) {
        event.preventDefault();
      }
    });
    keepOffline(
      toolbar,
      async () => {
        if (!(await this.grid.finishCell())) {
          throw new Error(STRINGS.measureSaveRefused);
        }
        await this.commitHeader();
        await this.autosave.flush();
      },
      showFailure,
    ).catch((error: unknown) => {
      console.warn('not kept for offline use', error);
    });
    this.run(this.loadCatalogue());
    this.run(this.offerLeftOver());
  }

  // Nothing depends on the catalogue, so without it the table still works
  private async loadCatalogue(): Promise<void> {
    const response = await fetch(new URL('./measurement-catalogue.json', import.meta.url));
    if (!response.ok) {
      showMessage(STRINGS.catalogueFailed(`${String(response.status)} ${response.statusText}`));
      return;
    }
    try {
      await this.document.loadCatalogue(await response.text());
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(STRINGS.catalogueFailed(error.message));
        return;
      }
      throw error;
    }
  }

  private showHighlight(): void {
    this.figure.highlight = this.gridHover === '' ? this.shownKey : this.gridHover;
  }

  private async showIn(unit: MeasureUnit): Promise<void> {
    await this.document.showIn(unit);
    this.catalogue.showUnit();
  }

  private run(pending: Promise<void>): void {
    pending.catch(showFailure);
  }

  private shortcutHint(command: string, hint: string): string {
    const keys = this.shortcuts.get(command) ?? '';
    return keys === '' ? hint : `${hint} (${shortcutText(keys)})`;
  }

  private keyDown(event: KeyboardEvent, buttons: Record<string, HTMLButtonElement>): void {
    const target = event.target;
    const editing =
      target instanceof HTMLInputElement ||
      target instanceof HTMLTextAreaElement ||
      target instanceof HTMLSelectElement ||
      (target instanceof HTMLElement && target.isContentEditable);
    for (const [command, button] of Object.entries(buttons)) {
      if (editing && (command === 'undo' || command === 'redo')) {
        continue;
      }
      const shortcut = parseShortcut(this.shortcuts.get(command) ?? '');
      if (shortcut !== undefined && matchesShortcut(event, shortcut)) {
        event.preventDefault();
        event.stopPropagation();
        button.click();
        return;
      }
    }
  }

  private async chooseOpen(): Promise<void> {
    if (this.fileBusy) {
      return;
    }
    if (this.files === undefined) {
      openInput.click();
      return;
    }
    const handle = await this.files.openMeasurements(this.fileHandle);
    if (handle !== undefined) {
      await this.openFile(await handle.getFile(), handle);
    }
  }

  // The user guide's measurement files, fetched from the site as Publish's examples
  private exampleBox(): HTMLSelectElement {
    const box = document.createElement('select');
    box.id = 'examples';
    box.title = STRINGS.measureExamplesHint;
    box.setAttribute('aria-label', STRINGS.measureExamplesHint);
    box.add(new Option(STRINGS.examples, '', true, true));
    for (const example of MEASUREMENT_EXAMPLES) {
      box.add(new Option(example.caption, example.path));
    }
    box.addEventListener('change', () => {
      const path = box.value;
      box.value = '';
      if (path !== '') {
        this.run(this.openExample(path));
      }
    });
    return box;
  }

  // Opened as any file without a handle, so Save asks where to put it
  private async openExample(path: string): Promise<void> {
    const file = await fetchExampleFile(new URL(`examples/${path}`, window.location.href));
    if (file === undefined) {
      showMessage(STRINGS.exampleMissing(baseName(path)));
      return;
    }
    await this.openFile(file);
  }

  private async mayReplace(): Promise<boolean> {
    const committed = await this.grid.finishCell();
    await this.commitHeader();
    return (committed && !this.document.state.modified) || window.confirm(STRINGS.measureDiscardChanges);
  }

  // A file that cannot be read keeps the set open, and says why. Changes not
  // saved are dropped only when the user agrees.
  private async openFile(file: File, handle?: FileSystemFileHandle): Promise<void> {
    if (this.fileBusy) {
      return;
    }
    if (!file.name.toLowerCase().endsWith(MEASUREMENTS_EXTENSION)) {
      showMessage(STRINGS.measureNotASet(file.name));
      return;
    }
    this.fileBusy = true;
    try {
      if (!(await this.mayReplace())) {
        return;
      }
      const text = await file.text();
      await this.document.open(text, file.name);
      this.fileHandle = handle;
      this.diskText = handle === undefined ? undefined : text;
      showMessage(STRINGS.measureOpened(file.name));
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(STRINGS.measureOpenFailed(file.name, error.message));
        return;
      }
      throw error;
    } finally {
      this.fileBusy = false;
    }
  }

  // As the desktop's Import: the file becomes a new set, named after it, not
  // saved and with nothing to undo, and the report says what changed. One
  // that cannot be read keeps the set open, and says why.
  private async importFile(file: File): Promise<void> {
    if (this.fileBusy) {
      return;
    }
    const dot = file.name.lastIndexOf('.');
    const extension = dot < 0 ? '' : file.name.slice(dot).toLowerCase();
    if (!SEAMLY_EXTENSIONS.has(extension)) {
      showMessage(STRINGS.seamlyNotAFile(file.name));
      return;
    }
    this.fileBusy = true;
    let report: ImportReport;
    try {
      if (!(await this.mayReplace())) {
        return;
      }
      report = await this.document.importSeamly(
        await file.text(),
        file.name,
        `${file.name.slice(0, dot)}${MEASUREMENTS_EXTENSION}`,
      );
      this.fileHandle = undefined;
      this.diskText = undefined;
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(error.message);
        return;
      }
      throw error;
    } finally {
      this.fileBusy = false;
    }
    showMessage(STRINGS.seamlyImported(file.name));
    const lines = [
      STRINGS.seamlyImportCounts(report.count, report.translated.length, report.kept.length, report.corrected.length),
    ];
    for (const [heading, section] of [
      [STRINGS.seamlyImportNotes, report.notes],
      [STRINGS.seamlyImportCorrected, report.corrected],
      [STRINGS.seamlyImportKept, report.kept],
      [STRINGS.seamlyImportTranslated, report.translated],
    ] as const) {
      if (section.length > 0) {
        lines.push('', heading, ...section.map((line) => `  ${line}`));
      }
    }
    this.reportDialog.open(STRINGS.seamlyImported(file.name), lines);
  }

  // As the desktop's Export: the cell being edited is committed first, and an
  // individual file from a size table holds the size whose column the chosen
  // cell is in. The file is downloaded, and what could not be carried over
  // exactly is reported.
  private async chooseExport(): Promise<void> {
    if (this.document.state.rows.length === 0 || !(await this.grid.finishCell())) {
      return;
    }
    await this.commitHeader();
    const sizes = this.document.state.sizes;
    const size = sizes.length === 0 ? undefined : Math.max(0, this.grid.chosenSize);
    const base = this.document.fileName.replace(/\.slm$/iu, '');
    this.exportDialog.open(size === undefined ? undefined : sizes[size], async (kind: SeamlyKind) => {
      const name = `${base}.${kind}`;
      let notes: string[];
      try {
        const exported = await this.document.exportSeamly(kind, size);
        downloadText(name, exported.text, 'application/xml');
        notes = exported.notes;
      } catch (error: unknown) {
        if (error instanceof EngineError) {
          return STRINGS.seamlyExportFailed(name, error.message);
        }
        throw error;
      }
      showMessage(STRINGS.downloaded(name));
      if (notes.length > 0) {
        this.reportDialog.open(STRINGS.seamlyExported(name), notes);
      }
      return undefined;
    });
  }

  private async save(saveAs: boolean): Promise<void> {
    const name = this.document.fileName;
    if (name === '' || this.fileBusy) {
      return;
    }
    this.fileBusy = true;
    const files = this.files;
    try {
      // The picker or permission request needs the button's user activation.
      let handle = saveAs ? undefined : this.fileHandle;
      if (files !== undefined) {
        if (handle !== undefined && !(await files.mayWrite(handle))) {
          showMessage(STRINGS.writeRefused(handle.name));
          return;
        }
        handle ??= await files.chooseSave(name, 'measurements', this.fileHandle);
        if (handle === undefined) {
          return;
        }
      }
      if (!(await this.grid.finishCell())) {
        showMessage(STRINGS.measureSaveRefused);
        return;
      }
      await this.commitHeader();
      const text = await this.document.text();
      if (files === undefined || handle === undefined) {
        downloadText(name, text);
        await this.document.saved(text, name);
        showMessage(STRINGS.downloaded(name));
        return;
      }
      if (this.fileHandle !== undefined && (await handle.isSameEntry(this.fileHandle))) {
        if ((await (await handle.getFile()).text()) !== this.diskText) {
          showMessage(STRINGS.measureFileChanged(handle.name));
          return;
        }
      }
      if (!(await files.write(handle, text))) {
        showMessage(STRINGS.writeRefused(handle.name));
        return;
      }
      this.fileHandle = handle;
      this.diskText = text;
      await this.document.saved(text, handle.name);
      showMessage(STRINGS.saved(handle.name));
    } finally {
      this.fileBusy = false;
    }
  }

  private async offerLeftOver(): Promise<void> {
    const [work] = await this.autosave.leftOver();
    if (work === undefined) {
      return;
    }
    const text = STRINGS.workLeftOver(work.fileName, new Date(work.time).toLocaleString());
    const open = plainButton(STRINGS.workOpen, STRINGS.workOpen, () => {
      this.run(this.openWork(work));
    });
    const discard = plainButton(STRINGS.workDiscard, STRINGS.workDiscard, () => {
      this.run(this.discardWork(work));
    });
    message.replaceChildren(text, ' ', open, ' ', discard);
  }

  private async discardWork(work: Work): Promise<void> {
    await this.autosave.discard(work);
    showMessage('');
    await this.offerLeftOver();
  }

  private async openWork(work: Work): Promise<void> {
    if (this.fileBusy) {
      return;
    }
    this.fileBusy = true;
    try {
      if (!(await this.mayReplace())) {
        return;
      }
      const texts = await this.autosave.texts(work);
      await this.document.open(texts.get(WORK_SET) ?? '', work.fileName);
      this.fileHandle = work.handles[WORK_SET];
      this.diskText = texts.get(WORK_DISK_TEXT);
      this.workKept = false;
      await this.document.markUnsaved();
      await this.autosave.flush();
      if (this.workKept) {
        await this.autosave.discard(work);
      }
      showMessage(STRINGS.workOpened(work.fileName));
    } finally {
      this.fileBusy = false;
    }
  }

  // A file that is not a pattern, or does not read as one, says why, and
  // the check before stays
  private async checkPattern(file: File): Promise<void> {
    if (!file.name.toLowerCase().endsWith(PATTERN_EXTENSION)) {
      showMessage(STRINGS.notAPattern(file.name));
      return;
    }
    try {
      await this.document.checkPattern(file.name, await file.text());
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(error.message);
        return;
      }
      throw error;
    }
    showMessage(STRINGS.checkingPattern(file.name));
  }

  // As the desktop's Add or go to it: a key the set lacks is added, and a
  // value it is short of is gone to, at that size
  private async fixMissing(item: MissingMeasurement): Promise<void> {
    const [size] = item.sizes;
    if (size !== undefined) {
      await this.grid.chooseValue(item.key, Math.max(0, this.document.state.sizes.indexOf(size)));
      return;
    }
    try {
      await this.document.addMissing(item.key);
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(error.message);
        return;
      }
      throw error;
    }
    await this.grid.chooseValue(item.key);
  }

  // The fields' text, where it differs from the set's, as the desktop's
  // HeaderDone; each change one undo step
  private async commitHeader(): Promise<void> {
    if (this.document.fileName === '') {
      return;
    }
    if (nameBox.value !== this.document.state.name) {
      await this.document.setName(nameBox.value);
    }
    if (notesBox.value !== this.document.state.notes) {
      await this.document.setNotes(notesBox.value);
    }
  }

  // A new measurement at the end, its key open to type, as on the desktop
  private async addMeasurement(): Promise<void> {
    await this.grid.editKey(await this.document.add());
  }

  // Asked first, as on the desktop, since patterns name it by its key
  private async deleteChosen(): Promise<void> {
    const key = this.grid.chosenKey;
    if (key === undefined || !window.confirm(STRINGS.measureDeleteQuestion(key))) {
      return;
    }
    await this.document.delete(key);
    this.grid.showSelection([]);
    this.refreshButtons();
  }

  // One place up (-1) or down (1); it stays chosen
  private async moveChosen(step: number): Promise<void> {
    const key = this.grid.chosenKey;
    const index = this.chosenIndex();
    if (key !== undefined && index >= 0) {
      await this.document.move(key, index + step);
    }
  }

  // A name refused, or the last size, says why in the status bar, as the
  // desktop's message does
  private async sizeEdit(edit: Promise<void>): Promise<void> {
    try {
      await edit;
    } catch (error: unknown) {
      if (error instanceof EngineError) {
        showMessage(error.message);
        return;
      }
      throw error;
    }
  }

  private async addSize(): Promise<void> {
    const name = window.prompt(STRINGS.measureSizePrompt, '');
    if (name !== null) {
      await this.sizeEdit(this.document.addSize(name));
    }
  }

  private async renameSize(): Promise<void> {
    const size = this.grid.chosenSize;
    const old = this.document.state.sizes[size];
    if (old === undefined) {
      return;
    }
    const name = window.prompt(`${STRINGS.measureRenameSizePrompt(old)}\n${STRINGS.measureSizePrompt}`, old);
    if (name !== null && name !== old) {
      await this.sizeEdit(this.document.renameSize(size, name));
    }
  }

  // Asked first, as on the desktop
  private async deleteSize(): Promise<void> {
    const size = this.grid.chosenSize;
    const name = this.document.state.sizes[size];
    if (name !== undefined && window.confirm(STRINGS.measureDeleteSizeQuestion(name))) {
      await this.sizeEdit(this.document.deleteSize(size));
      this.refreshButtons();
    }
  }

  // One column left (-1) or right (1); the chosen cell goes with it
  private async moveSize(step: number): Promise<void> {
    const size = this.grid.chosenSize;
    const index = size + step;
    if (size >= 0 && index >= 0 && index < this.document.state.sizes.length) {
      await this.document.moveSize(size, index);
      this.grid.chooseSize(index);
    }
  }

  // The chosen measurement's row, or -1
  private chosenIndex(): number {
    return this.document.state.rows.findIndex((row) => row.key === this.grid.chosenKey);
  }

  private refreshButtons(): void {
    const state = this.document.state;
    const index = this.chosenIndex();
    this.undoButton.disabled = !state.canUndo;
    this.undoButton.title = this.shortcutHint('undo', state.canUndo ? STRINGS.undoStep(state.undo) : STRINGS.undoHint);
    this.redoButton.disabled = !state.canRedo;
    this.redoButton.title = this.shortcutHint('redo', STRINGS.redoHint);
    this.saveButton.disabled = this.document.fileName === '';
    this.saveAsButton.disabled = this.saveButton.disabled;
    this.addButton.disabled = this.document.fileName === '';
    this.exportButton.disabled = state.rows.length === 0;
    this.checkButton.disabled = this.document.fileName === '';
    this.stopCheckButton.disabled = state.pattern === '';
    this.deleteButton.disabled = index < 0;
    this.upButton.disabled = index <= 0;
    this.downButton.disabled = index < 0 || index >= state.rows.length - 1;
    const size = this.grid.chosenSize;
    this.addSizeButton.disabled = this.document.fileName === '';
    this.renameSizeButton.disabled = size < 0;
    this.deleteSizeButton.disabled = size < 0;
    this.sizeLeftButton.disabled = size <= 0;
    this.sizeRightButton.disabled = size < 0 || size >= state.sizes.length - 1;
    document.body.dataset.undo = state.canUndo ? state.undo : '';
  }

  private showState(): void {
    const state = this.document.state;
    const fileName = this.document.fileName;
    const shown = state.modified ? `${STRINGS.modifiedMark} ${fileName}` : fileName;
    document.title = fileName === '' ? STRINGS.measureApp : `${shown} — ${STRINGS.measureApp}`;
    // A field with text not yet committed keeps it, as the desktop's field
    // being typed in, unless another set was opened
    const opened = this.document.generation !== this.shownGeneration;
    this.shownGeneration = this.document.generation;
    for (const [box, text, before] of [
      [nameBox, state.name, this.shownName],
      [notesBox, state.notes, this.shownNotes],
    ] as const) {
      if (opened || box.value === before) {
        box.value = text;
      }
      box.disabled = fileName === '';
    }
    this.shownName = state.name;
    this.shownNotes = state.notes;
    // The table once a set is open, else a line saying to open one
    if (fileName === '') {
      table.replaceChildren(empty);
    } else if (!table.contains(this.grid.element)) {
      table.replaceChildren(this.grid.element);
    }
    this.grid.showSet(opened);
    this.catalogue.refresh();
    this.figure.refresh();
    this.patternCheck.refresh();
    this.refreshButtons();
  }
}

async function main(): Promise<void> {
  showMessage(STRINGS.loading);
  const { engine } = await Engine.start(
    new URL('./worker.js', import.meta.url),
    new URL('./engine_lib.wasm', import.meta.url),
  );
  const tables = await engine.call('measurements_tables');
  const shortcuts = new Map(
    recordsField(tables, 'shortcuts').map((row): [string, string] => [
      stringField(row, 'command') ?? '',
      stringField(row, 'keys') ?? '',
    ]),
  );
  new MeasurementsApp(engine, shortcuts).start();
  showMessage('');
  document.body.dataset.ready = 'true';
}

main().catch(showFailure);
