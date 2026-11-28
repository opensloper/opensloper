// The web Measurements app's Export… and import report, as the desktop's
// Export save dialog, whose filter chooses the kind of file, and its
// ShowReport window. Export writes a Seamly2D or Valentina file: multi-size
// from a size table, or individual of one size, the column the chosen cell
// is in. The report lists what Import or Export could not carry over
// exactly.
import { SEAMLY_KINDS, type SeamlyKind } from '../document/measurementDocument.ts';
import { STRINGS } from '../ui/strings.ts';

function make<K extends keyof HTMLElementTagNameMap>(tag: K, className = ''): HTMLElementTagNameMap[K] {
  const element = window.document.createElement(tag);
  element.className = className;
  return element;
}

function button(caption: string, action: () => void): HTMLButtonElement {
  const result = make('button');
  result.type = 'button';
  result.textContent = caption;
  result.addEventListener('click', action);
  return result;
}

// Writes the kind chosen, answering the reason when it is refused
export type ExportAction = (kind: SeamlyKind) => Promise<string | undefined>;

export class ExportDialog {
  private readonly dialog = make('dialog', 'seamly-dialog');
  private readonly kinds = make('div', 'seamly-kinds');
  private readonly refusal = make('p', 'seamly-refusal');
  private readonly exportButton: HTMLButtonElement;
  private action: ExportAction = () => Promise.resolve(undefined);

  constructor(private readonly failed: (error: unknown) => void) {
    const title = make('h2');
    title.textContent = STRINGS.seamlyExportTitle;
    const about = make('p', 'seamly-about');
    about.textContent = STRINGS.seamlyExportAbout;
    this.exportButton = button(STRINGS.seamlyExport, () => {
      this.run();
    });
    this.exportButton.classList.add('default');
    const cancel = button(STRINGS.seamlyCancel, () => {
      this.dialog.close();
    });
    const buttons = make('div', 'seamly-buttons');
    buttons.append(this.exportButton, cancel);
    this.dialog.append(title, about, this.kinds, this.refusal, buttons);
    window.document.body.append(this.dialog);
  }

  // A size table offers the multi-size kinds first, and an individual file
  // of the size given; a set without sizes only the individual kinds
  open(size: string | undefined, action: ExportAction): void {
    this.action = action;
    const kinds = size === undefined ? SEAMLY_KINDS.filter((kind) => kind === 'smis' || kind === 'vit') : SEAMLY_KINDS;
    this.kinds.replaceChildren(
      ...kinds.map((kind, index) => {
        const label = make('label');
        const radio = make('input');
        radio.type = 'radio';
        radio.name = 'seamly-kind';
        radio.value = kind;
        radio.checked = index === 0;
        label.append(radio, ` ${STRINGS.seamlyKind(kind, size)}`);
        return label;
      }),
    );
    this.refusal.textContent = '';
    this.exportButton.disabled = false;
    this.dialog.showModal();
    this.exportButton.focus();
  }

  private chosen(): SeamlyKind | undefined {
    const radio = this.kinds.querySelector<HTMLInputElement>('input:checked');
    return SEAMLY_KINDS.find((kind) => kind === radio?.value);
  }

  // A refusal stays in the dialog, so another kind can be chosen
  private run(): void {
    const kind = this.chosen();
    if (kind !== undefined) {
      this.write(kind).catch((error: unknown) => {
        this.dialog.close();
        this.failed(error);
      });
    }
  }

  private async write(kind: SeamlyKind): Promise<void> {
    this.exportButton.disabled = true;
    try {
      const reason = await this.action(kind);
      if (reason === undefined) {
        this.dialog.close();
      } else {
        this.refusal.textContent = reason;
      }
    } finally {
      this.exportButton.disabled = false;
    }
  }
}

// The desktop's ShowReport: a title, the lines and Close
export class ReportDialog {
  private readonly dialog = make('dialog', 'seamly-dialog');
  private readonly title = make('h2');
  private readonly body = make('textarea', 'seamly-report');

  constructor() {
    this.body.readOnly = true;
    this.body.rows = 14;
    const close = button(STRINGS.seamlyClose, () => {
      this.dialog.close();
    });
    close.classList.add('default');
    const buttons = make('div', 'seamly-buttons');
    buttons.append(close);
    this.dialog.append(this.title, this.body, buttons);
    window.document.body.append(this.dialog);
  }

  open(title: string, lines: readonly string[]): void {
    this.title.textContent = title;
    this.body.value = lines.join('\n');
    this.dialog.showModal();
    this.body.scrollTop = 0;
  }
}
