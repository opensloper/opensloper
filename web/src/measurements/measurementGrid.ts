// The measurements page's table, as the desktop measurements window's grid:
// a row a measurement, with its key, a value column a size (or one Value
// column for a set without sizes) and its description. Every cell is edited
// in the grid, each edit one undo step; a refused one stays red with the
// reason, as on the desktop. The rows come from the document's state, which
// the engine gives with the values already in the unit chosen; the page
// tells the grid to build them again when the set or the unit changes.
import type { MeasurementColumn, MeasurementDocument } from '../document/measurementDocument.ts';
import {
  ListPanel,
  type CellCommit,
  type ListColumn,
  type ListPanelEvents,
  type ListPanelRow,
} from '../ui/listPanel.ts';
import { STRINGS } from '../ui/strings.ts';

// CSS pixels, as the desktop's column widths
const KEY_WIDTH = 190;
const VALUE_WIDTH = 80;
const DESCRIPTION_WIDTH = 320;
const KEY_COLUMN = 0;

export interface MeasurementGridEvents extends ListPanelEvents {
  // Delete was pressed in the grid, for the page to ask and delete
  delete(): void;
  // The current cell moved to another column, so another size may be chosen
  column(): void;
}

export class MeasurementGrid extends ListPanel<MeasurementDocument> {
  private readonly gridEvents: MeasurementGridEvents;
  private sizes: readonly string[] = [];
  private columnCount = 0;

  constructor(document: MeasurementDocument, events: MeasurementGridEvents) {
    super(document, events, []);
    this.gridEvents = events;
    // There is no search, as on the desktop
    this.header.hidden = true;
    this.useColumns([]);
    this.setShown(true);
  }

  // The measurement chosen, or undefined
  get chosenKey(): string | undefined {
    return this.selection[0];
  }

  // The size whose column the current cell of the chosen row is in, by its
  // index from 0, or -1, as the desktop's size buttons need
  get chosenSize(): number {
    const size = this.chosenColumn - 1;
    return this.chosenKey === undefined || size < 0 || size >= this.sizes.length ? -1 : size;
  }

  // Moves the current cell to the size's column, as after moving the size
  chooseSize(size: number): void {
    const key = this.chosenKey;
    if (key !== undefined) {
      this.focusCell(key, size + 1, false);
    }
  }

  // Chooses the measurement at a size's value, the first by default, as
  // after adding it from the catalogue, once its row is listed
  async chooseValue(key: string, size = 0): Promise<void> {
    await this.rowsLoaded();
    this.focusCell(key, KEY_COLUMN + 1 + size, false);
  }

  // The set or the unit changed: the columns follow its sizes
  showSet(opened: boolean): void {
    if (opened) {
      this.clearRefusals();
    }
    const sizes = this.document.state.sizes;
    if (
      this.columnCount === 0 ||
      sizes.length !== this.sizes.length ||
      sizes.some((size, i) => size !== this.sizes[i])
    ) {
      this.useColumns(sizes);
    }
    this.refresh();
  }

  // Chooses the measurement and opens its key to type, as after Add
  async editKey(key: string): Promise<void> {
    await this.rowsLoaded();
    this.focusCell(key, KEY_COLUMN, true);
  }

  protected async buildRows(): Promise<ListPanelRow[]> {
    return Promise.resolve(
      this.document.state.rows.map((row) => ({
        key: row.key,
        cells: [row.key, ...row.values, row.description],
        warned: [false, ...row.outside, false],
        state: 'valid',
      })),
    );
  }

  protected override async commitCell(key: string, column: number, text: string): Promise<CellCommit> {
    const [kind, size] = this.cellOf(column);
    const result = await this.document.setCell(key, kind, size, text);
    // As the desktop says, since patterns name measurements by their keys
    if (result.done && result.key !== key) {
      this.events.message(STRINGS.measureRenamed(result.key, key));
    }
    // As the desktop's status bar: the value is kept, the cell tinted
    if (result.warning !== '') {
      this.events.message(result.warning);
    }
    return result;
  }

  protected override deleteRequested(): void {
    this.gridEvents.delete();
  }

  protected override columnChanged(): void {
    this.gridEvents.column();
  }

  private useColumns(sizes: readonly string[]): void {
    this.sizes = [...sizes];
    const values = sizes.length === 0 ? [STRINGS.measureColumnValue] : sizes;
    const columns: ListColumn[] = [
      { caption: STRINGS.measureColumnKey, width: KEY_WIDTH },
      ...values.map((caption) => ({ caption, width: VALUE_WIDTH })),
      { caption: STRINGS.measureColumnDescription, width: DESCRIPTION_WIDTH },
    ];
    this.columnCount = columns.length;
    this.setColumns(columns);
    this.setEditableColumns(
      columns.map(() => true),
      columns.map(() => false),
    );
  }

  // The cell a column holds: the key, a size's value or the description
  private cellOf(column: number): [MeasurementColumn, number] {
    if (column === KEY_COLUMN) {
      return ['key', 0];
    }
    if (column === this.columnCount - 1) {
      return ['description', 0];
    }
    return ['value', column - 1];
  }
}
