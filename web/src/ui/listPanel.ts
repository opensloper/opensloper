// The list behind the side panel's tabs, as Sloper.UI.ListPanel: a search box
// over a grid of rows, held by key, since undo and redo replace the pattern's
// objects. Each tab says what its rows are. The panel keeps the selection
// itself and paints it; a click asks the engine what it selects
// (editor_list_click), as SelectionAfterClick decides it on the desktop.
// Rows are built again after each change while the tab shows, and once it
// shows again after changes made while it was hidden.
//
// A tab can make some of its columns editable. Its rows are then edited in
// the grid: typing, F2, Enter or a double-click opens the current cell,
// Enter, Tab or leaving the cell commits it through commitCell, and Escape
// puts the text back. A refused value keeps its text, with the cell in red and
// the reason sent to message, until it is committed or Escape is pressed on
// it. Editable panels choose one row at a time, with a current cell in it.
//
// A pattern's lists follow its document's changes. A list of another
// document, such as the measurements page's table, is told by its owner when
// to build its rows again (refresh), and chooses one row at a time.
import { PatternDocument, type DocumentChange } from '../document/patternDocument.ts';
import { EngineError } from '../engine/engine.ts';
import { idsField, type JsonRecord } from '../engine/replies.ts';
import type { EvalState } from '../editor/scene.ts';
import { FormulaCompleter } from './formulaCompleter.ts';
import { LatestOnly } from './latestOnly.ts';
import type { SideTabContent } from './sideTabs.ts';
import { STRINGS } from './strings.ts';

export interface ListPanelRow {
  key: string;
  cells: string[];
  state: EvalState;
  // Shown in bold, as an unsaved edit
  marked?: boolean;
  // Cells tinted as a warning, such as a value outside its typical range
  warned?: readonly boolean[];
}

export interface ListColumn {
  caption: string;
  // CSS pixels, as the desktop's widths at 96 pixels per inch
  width: number;
}

export interface ListPanelEvents {
  // The user chose rows in the list
  select(keys: readonly string[]): void;
  // The user double-clicked a row of a list that cannot be edited
  zoom(): void;
  // A hint or the reason something could not be done
  message(text: string): void;
  failed(error: unknown): void;
}

// What committing a cell did: refused, with the reason, or done; key is the
// row's key afterwards when the edit changed it
export interface CellCommit {
  done: boolean;
  reason: string;
  key?: string;
}

// The cell being edited, by key, as rows may move
interface OpenCell {
  key: string;
  column: number;
  input: HTMLInputElement;
}

function refusalKey(key: string, column: number): string {
  return `${key}\t${String(column)}`;
}

// What a list reads its rows from
export interface ListDocument {
  read(method: string, params?: object): Promise<JsonRecord>;
}

export abstract class ListPanel<D extends ListDocument = PatternDocument> implements SideTabContent {
  readonly element: HTMLElement;
  protected readonly document: D;
  protected readonly header: HTMLElement;
  protected readonly events: ListPanelEvents;
  // Several rows can be chosen at once with Ctrl or Shift
  protected multiSelect = true;
  private readonly search: HTMLInputElement;
  private readonly scroller: HTMLElement;
  private readonly widths: HTMLTableColElement;
  private readonly head: HTMLTableRowElement;
  private readonly body: HTMLTableSectionElement;
  private readonly refreshes: LatestOnly<number>;
  private rows: ListPanelRow[] = [];
  private selected: string[] = [];
  // The selected row is brought into view once it is listed
  private revealPending = false;
  private anchor = '';
  private shown = false;
  // Changes came while the tab was hidden, or while a cell was open
  private stale = true;
  private editable: boolean[] = [];
  private formula: boolean[] = [];
  private currentColumn = 0;
  private open: OpenCell | undefined;
  private readonly pendingCommits = new Set<Promise<boolean>>();
  // Refused text by row and column, shown over the value it would have replaced
  private readonly refusals = new Map<string, string>();
  private completer: FormulaCompleter | undefined;
  private readonly listener = (_document: PatternDocument, changes: ReadonlySet<DocumentChange>): void => {
    if (changes.has('objectsReplaced')) {
      this.refusals.clear();
    }
    if (changes.has('pattern') || changes.has('objectsReplaced') || changes.has('measurements')) {
      this.refresh();
    }
  };

  protected constructor(document: D, events: ListPanelEvents, columns: readonly ListColumn[]) {
    this.document = document;
    this.events = events;
    this.element = window.document.createElement('div');
    this.element.className = 'list-panel';
    this.header = window.document.createElement('div');
    this.header.className = 'list-header';
    this.search = window.document.createElement('input');
    this.search.type = 'search';
    this.search.placeholder = STRINGS.listSearch;
    this.search.setAttribute('aria-label', STRINGS.listSearch);
    this.search.addEventListener('input', () => {
      this.refresh();
    });
    this.header.append(this.search);
    this.scroller = window.document.createElement('div');
    this.scroller.className = 'list-scroller';
    this.scroller.tabIndex = 0;
    this.scroller.addEventListener('keydown', (event) => {
      this.gridKey(event);
    });
    const table = window.document.createElement('table');
    table.className = 'list-grid';
    this.widths = window.document.createElement('colgroup');
    this.head = table.createTHead().insertRow();
    this.setColumns(columns);
    table.prepend(this.widths);
    this.body = table.createTBody();
    this.body.addEventListener('mousedown', (event) => {
      this.rowPressed(event);
    });
    this.body.addEventListener('dblclick', (event) => {
      if (this.isEditable) {
        if (!(event.target instanceof HTMLInputElement)) {
          this.openCell('');
        }
      } else {
        this.events.zoom();
      }
    });
    this.scroller.append(table);
    this.element.append(this.header, this.scroller);
    this.refreshes = new LatestOnly(
      async () => this.loadRows(),
      (error) => {
        this.report(error);
      },
    );
    if (document instanceof PatternDocument) {
      document.addListener(this.listener);
    }
  }

  // What the tab lists, for the search text
  protected abstract buildRows(search: string): Promise<ListPanelRow[]>;

  // Makes the edit; done false refuses it, with the reason shown to the user
  protected async commitCell(_key: string, _column: number, _text: string): Promise<CellCommit> {
    return Promise.resolve({ done: false, reason: '' });
  }

  // Whether the row's cell can be opened; by default its column decides
  protected cellEditable(_key: string, column: number): boolean {
    return this.editable[column] === true;
  }

  // The text an opened cell starts with, from the text it shows
  protected cellEditText(_key: string, _column: number, shown: string): string {
    return shown;
  }

  // The object or variable a formula column's row is, for completion
  protected completionTarget(key: string): number | undefined {
    return /^\d+$/.test(key) ? Number(key) : undefined;
  }

  // Delete was pressed in the list
  protected deleteRequested(): void {
    // Nothing to delete in a plain list
  }

  // The current cell moved to another column of the chosen row
  protected columnChanged(): void {
    // A plain list has no current cell
  }

  // The column of the current cell, from 0
  protected get chosenColumn(): number {
    return this.currentColumn;
  }

  // Turns on editing in the grid. Formula columns offer name completion. The
  // current cell keeps its column while that column is still editable.
  protected setEditableColumns(editable: readonly boolean[], formula: readonly boolean[]): void {
    this.editable = [...editable];
    this.formula = [...formula];
    this.multiSelect = false;
    if (this.editable[this.currentColumn] !== true) {
      this.currentColumn = Math.max(0, this.editable.indexOf(true));
    }
  }

  // Keys of the selected rows
  get selection(): readonly string[] {
    return this.selected;
  }

  // The keys of the rows listed, filter and search applied, in list order
  get visibleKeys(): string[] {
    return this.rows.map((row) => row.key);
  }

  setShown(shown: boolean): void {
    this.shown = shown;
    if (shown && this.stale) {
      this.refresh();
    }
  }

  // Follows a selection made elsewhere, without telling select
  showSelection(keys: readonly string[]): void {
    this.selected = [...keys];
    this.paintSelection();
  }

  // Selects these rows for something chosen elsewhere, such as a problem,
  // and brings the first into view, now or once the list is built
  chooseKeys(keys: readonly string[]): void {
    this.revealPending = true;
    this.showSelection(keys);
  }

  // Stops listening to the document, so a closed panel is not kept alive
  dispose(): void {
    if (this.document instanceof PatternDocument) {
      this.document.removeListener(this.listener);
    }
    this.completer?.dispose();
  }

  // The grid's columns, as a measurement table has one a size; the rows are
  // built again by the next refresh
  protected setColumns(columns: readonly ListColumn[]): void {
    this.widths.replaceChildren(
      ...columns.map((column) => {
        const col = window.document.createElement('col');
        col.style.width = `${String(column.width)}px`;
        return col;
      }),
    );
    this.head.replaceChildren(
      ...columns.map((column) => {
        const cell = window.document.createElement('th');
        cell.textContent = column.caption;
        return cell;
      }),
    );
  }

  // Builds the rows again, now when the tab shows and no cell is open, else
  // when it next shows or the cell closes
  protected refresh(): void {
    if (this.shown && this.open === undefined) {
      this.stale = false;
      this.refreshes.push(0);
    } else {
      this.stale = true;
    }
  }

  // Waits for the rows asked for so far
  protected async rowsLoaded(): Promise<void> {
    await this.refreshes.idle();
  }

  // Selects the row as the user would, and moves to its cell, opening it when edit is set
  protected focusCell(key: string, column: number, edit: boolean): void {
    this.selected = [key];
    this.anchor = key;
    this.currentColumn = column;
    this.paintSelection();
    this.events.select(this.selected);
    if (edit) {
      this.openCell('');
    } else {
      this.scroller.focus();
    }
  }

  // Drops the refused text kept in cells, as when the edits are reverted
  protected clearRefusals(): void {
    this.refusals.clear();
  }

  // A file operation needs the committed table, including a cell that just lost focus.
  async finishCell(): Promise<boolean> {
    this.closeCell(true, 0);
    const results = await Promise.all(this.pendingCommits);
    return results.every((done) => done) && this.refusals.size === 0;
  }

  protected report(error: unknown): void {
    if (error instanceof EngineError) {
      this.events.message(error.message);
    } else {
      this.events.failed(error);
    }
  }

  private get isEditable(): boolean {
    return this.editable.includes(true);
  }

  private async loadRows(): Promise<void> {
    const rows = await this.buildRows(this.search.value);
    // A cell opened while the rows were asked for: they come again when it closes
    if (this.open !== undefined) {
      this.stale = true;
      return;
    }
    this.rows = rows;
    const shown = new Set(this.rows.map((row) => row.key));
    for (const key of this.refusals.keys()) {
      if (!shown.has(key.split('\t')[0] ?? '')) {
        this.refusals.delete(key);
      }
    }
    const lines = this.rows.map((row) => {
      const line = window.document.createElement('tr');
      line.dataset.key = row.key;
      line.classList.toggle('marked', row.marked === true);
      if (row.state === 'error' || row.state === 'invalid') {
        line.classList.add('failed');
      } else if (row.state === 'blocked') {
        line.classList.add('blocked');
      }
      for (const [column, value] of row.cells.entries()) {
        const cell = window.document.createElement('td');
        const refused = this.refusals.get(refusalKey(row.key, column));
        const text = refused ?? value;
        cell.textContent = text;
        cell.title = text;
        cell.classList.toggle('refused', refused !== undefined);
        cell.classList.toggle('warned', row.warned?.[column] === true);
        line.append(cell);
      }
      return line;
    });
    this.body.replaceChildren(...lines);
    this.paintSelection();
  }

  private paintSelection(): void {
    const chosen = new Set(this.selected);
    for (const line of this.body.rows) {
      const selected = chosen.has(line.dataset.key ?? '');
      line.classList.toggle('selected', selected);
      for (const [column, cell] of [...line.cells].entries()) {
        cell.classList.toggle('current', selected && this.isEditable && column === this.currentColumn);
      }
      if (selected && this.revealPending) {
        this.revealPending = false;
        line.scrollIntoView({ block: 'nearest' });
      }
    }
  }

  private rowPressed(event: MouseEvent): void {
    // The second press of a double-click leaves the selection for the zoom or the edit
    if (event.button !== 0 || event.detail > 1 || !(event.target instanceof Element)) {
      return;
    }
    if (event.target instanceof HTMLInputElement) {
      return;
    }
    const cell = event.target.closest('td');
    const key = cell?.parentElement?.dataset.key;
    if (cell === null || key === undefined) {
      return;
    }
    event.preventDefault();
    this.scroller.focus();
    if (this.isEditable) {
      const moved = this.currentColumn !== cell.cellIndex;
      this.currentColumn = cell.cellIndex;
      // Moving along a row of an editable list is not a new choice
      if (this.selected.length === 1 && this.selected[0] === key) {
        this.paintSelection();
        if (moved) {
          this.columnChanged();
        }
        return;
      }
    }
    const toggle = this.multiSelect && (event.ctrlKey || event.metaKey);
    const extend = this.multiSelect && event.shiftKey;
    this.chooseRow(key, toggle, extend).catch((error: unknown) => {
      this.report(error);
    });
  }

  private async chooseRow(key: string, toggle: boolean, extend: boolean): Promise<void> {
    // One row at a time needs no asking, and keys typed straight after the click find it chosen
    if (!this.multiSelect) {
      this.selected = [key];
      this.anchor = key;
      this.paintSelection();
      this.events.select(this.selected);
      return;
    }
    const answer = await this.document.read('editor_list_click', {
      visible: this.visibleKeys,
      selected: this.selected,
      anchor: this.anchor,
      clicked: key,
      toggle,
      extend,
    });
    this.selected = idsField(answer, 'selection');
    if (!extend) {
      this.anchor = key;
    }
    this.paintSelection();
    this.events.select(this.selected);
  }

  // Arrows move, Enter, F2 or typing opens the current cell, Delete asks the tab
  private gridKey(event: KeyboardEvent): void {
    if (event.target !== this.scroller) {
      return;
    }
    const index = this.rows.findIndex((row) => row.key === this.selected[0]);
    let handled = true;
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      const next = this.rows[Math.max(0, Math.min(this.rows.length - 1, index + (event.key === 'ArrowDown' ? 1 : -1)))];
      if (next !== undefined) {
        this.chooseRow(next.key, false, false).catch((error: unknown) => {
          this.report(error);
        });
        this.body.querySelector(`tr[data-key="${CSS.escape(next.key)}"]`)?.scrollIntoView({ block: 'nearest' });
      }
    } else if (this.isEditable && (event.key === 'ArrowLeft' || event.key === 'ArrowRight')) {
      this.moveColumn(event.key === 'ArrowRight' ? 1 : -1, false);
    } else if (this.isEditable && (event.key === 'Enter' || event.key === 'F2')) {
      this.openCell('');
    } else if (this.isEditable && event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
      // Typing replaces the cell's text, as in a spreadsheet
      this.openCell(event.key);
    } else if (event.key === 'Delete' || event.key === 'Backspace') {
      this.deleteRequested();
    } else {
      handled = false;
    }
    if (handled) {
      // The list's keys are not the app's shortcuts
      event.preventDefault();
      event.stopPropagation();
    }
  }

  // To the next or previous column, editable ones only when editableOnly
  private moveColumn(step: number, editableOnly: boolean): void {
    let column = this.currentColumn;
    for (let count = 0; count < this.editable.length; count++) {
      column = Math.max(0, Math.min(this.editable.length - 1, column + step));
      if (!editableOnly || this.editable[column] === true) {
        break;
      }
    }
    const moved = this.currentColumn !== column;
    this.currentColumn = column;
    this.paintSelection();
    if (moved) {
      this.columnChanged();
    }
  }

  // Opens the current cell of the selected row; typed, when given, replaces its text
  private openCell(typed: string): void {
    const key = this.selected[0];
    const column = this.currentColumn;
    if (key === undefined || !this.cellEditable(key, column) || this.open !== undefined) {
      return;
    }
    const row = this.rows.find((each) => each.key === key);
    const cell = this.body.querySelector(`tr[data-key="${CSS.escape(key)}"]`)?.children[column];
    if (row === undefined || !(cell instanceof HTMLTableCellElement)) {
      return;
    }
    const input = window.document.createElement('input');
    input.className = 'cell-editor';
    input.value =
      typed === ''
        ? (this.refusals.get(refusalKey(key, column)) ?? this.cellEditText(key, column, row.cells[column] ?? ''))
        : typed;
    cell.replaceChildren(input);
    cell.classList.add('editing');
    this.open = { key, column, input };
    input.focus();
    if (typed === '') {
      input.select();
    }
    input.addEventListener('keydown', (event) => {
      this.editorKey(event);
    });
    input.addEventListener('input', () => {
      this.updateCompletion(false);
    });
    input.addEventListener('blur', () => {
      this.closeCell(true, 0);
    });
    if (typed !== '') {
      this.updateCompletion(false);
    }
  }

  private editorKey(event: KeyboardEvent): void {
    if (this.completer?.handleKey(event) === true) {
      event.stopPropagation();
      return;
    }
    if (event.key === ' ' && (event.ctrlKey || event.metaKey)) {
      this.updateCompletion(true);
    } else if (event.key === 'Enter') {
      this.closeCell(true, 0);
    } else if (event.key === 'Tab') {
      this.closeCell(true, event.shiftKey ? -1 : 1);
    } else if (event.key === 'Escape') {
      this.closeCell(false, 0);
    } else {
      if (['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) {
        this.completer?.hide();
      }
      // Keys typed in the cell are the cell's, not the app's shortcuts
      event.stopPropagation();
      return;
    }
    event.preventDefault();
    event.stopPropagation();
  }

  private updateCompletion(explicit: boolean): void {
    const open = this.open;
    // Formulas are completed from a pattern's names
    if (open === undefined || this.formula[open.column] !== true || !(this.document instanceof PatternDocument)) {
      return;
    }
    this.completer ??= new FormulaCompleter(this.document, (error) => {
      this.report(error);
    });
    this.completer.update(open.input, this.completionTarget(open.key), explicit);
  }

  // Closes the open cell, committing its text when commit is set, then moves step columns along
  private closeCell(commit: boolean, step: number): void {
    const open = this.open;
    if (open === undefined) {
      return;
    }
    this.open = undefined;
    this.completer?.hide();
    const text = open.input.value;
    const id = refusalKey(open.key, open.column);
    const row = this.rows.find((each) => each.key === open.key);
    const unchanged =
      text === this.cellEditText(open.key, open.column, row?.cells[open.column] ?? '') && !this.refusals.has(id);
    if (!commit) {
      this.refusals.delete(id);
    }
    if (step !== 0) {
      this.moveColumn(step, true);
    }
    this.scroller.focus();
    if (!commit || unchanged) {
      this.refresh();
      return;
    }
    // The cell shows what was typed until the rows come back
    open.input.replaceWith(text);
    const pending = this.commit(open, text).catch((error: unknown) => {
      this.report(error);
      this.refresh();
      return false;
    });
    this.pendingCommits.add(pending);
    void pending.then(() => this.pendingCommits.delete(pending));
  }

  // The row's key changed: the selection and a cell opened meanwhile follow it
  // A row's key changed, as a renamed measurement's; the owner hears of it
  // when the row was chosen, as the chosen key is now another
  private rekey(from: string, to: string): void {
    const chosen = this.selected.includes(from);
    this.selected = this.selected.map((key) => (key === from ? to : key));
    if (this.anchor === from) {
      this.anchor = to;
    }
    if (this.open?.key === from) {
      this.open.key = to;
    }
    for (const row of this.rows) {
      if (row.key === from) {
        row.key = to;
      }
    }
    for (const line of this.body.rows) {
      if (line.dataset.key === from) {
        line.dataset.key = to;
      }
    }
    this.paintSelection();
    if (chosen) {
      this.events.select(this.selected);
    }
  }

  private async commit(open: OpenCell, text: string): Promise<boolean> {
    const id = refusalKey(open.key, open.column);
    const result = await this.commitCell(open.key, open.column, text);
    if (result.done) {
      this.refusals.delete(id);
      if (result.key !== undefined && result.key !== open.key) {
        this.rekey(open.key, result.key);
      }
    } else {
      this.refusals.set(id, text);
      this.events.message(result.reason);
    }
    // A change refreshed the rows already; a refusal changed nothing, so show it now
    this.refresh();
    return result.done;
  }
}
