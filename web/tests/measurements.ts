// Drives the built Measurements app in headless Chromium: the page asks for a
// file until one is open; a set opens with its name, notes and a row a
// measurement; Show in shows the values in cm and inches. Name and Notes
// are edited, committed by Enter or leaving the field. A measurement is
// added from the catalogue, and a value outside its typical range warned of.
// The set is checked against a pattern, and a measurement it lacks added. In
// the grid a value
// is changed, one that is not a number refused, a key renamed and a
// description typed; Add makes a row whose key is typed, Up moves it, Delete
// asks and deletes it, and Undo and Redo step through. Opening another file
// asks before dropping the changes. A size table has a column a size, and a
// file that is not a measurement file, or cannot be read, is refused with the
// set open kept. Its sizes are renamed, moved, added and deleted with the size
// buttons, which act on the column of the chosen cell. The body figure
// highlights the row under the pointer, and a click on it chooses a row. SCREENSHOT, as in design.ts, keeps
// the page at the end.
import assert from 'node:assert/strict';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { Page } from 'puppeteer-core';
import { isRecord, recordsField, stringField } from '../src/engine/replies.ts';
import { launchBrowser, serveApp, status, waitForData, waitForStatus, watchProblems } from './browser.ts';

const SET = '../docs/examples/skirt-block/skirt.slm';
const SIZE_TABLE = '../docs/examples/measurements/size-table.slm';
const PATTERN = '../docs/examples/skirt-block/skirt-darts.sloper';
const BODICE = '../docs/examples/bodice-block/bodice-block.sloper';

// The table's captions, and its rows' cells
async function table(page: Page): Promise<{ head: string[]; rows: string[][] }> {
  return page.$eval('#table', (element) => ({
    head: [...element.querySelectorAll('th')].map((cell) => cell.textContent),
    rows: [...element.querySelectorAll('tbody tr')].map((row) =>
      [...row.querySelectorAll('td')].map((cell) => cell.textContent),
    ),
  }));
}

async function waitForRows(page: Page, count: number): Promise<void> {
  await page.waitForFunction((expected) => document.querySelectorAll('#table tbody tr').length === expected, {}, count);
}

// The table's cell, from 1 as CSS counts
function cellAt(row: number, column: number): string {
  return `#table tbody tr:nth-child(${String(row)}) td:nth-child(${String(column)})`;
}

async function keys(page: Page): Promise<string[]> {
  return page.$$eval('#table tbody tr', (rows) => rows.map((row) => (row as HTMLElement).dataset.key ?? ''));
}

// Clicks the button with this caption, once it is enabled
async function press(page: Page, caption: string): Promise<void> {
  await page.waitForFunction(
    (text) => {
      const button = [...document.querySelectorAll('button')].find(
        (each) => each.textContent === text && !each.disabled,
      );
      button?.click();
      return button !== undefined;
    },
    {},
    caption,
  );
}

// A downloaded file, once the browser has written it
async function readDownload(path: string): Promise<string> {
  let text = '';
  for (let attempt = 0; attempt < 50 && text === ''; attempt++) {
    // oxlint-disable-next-line no-await-in-loop
    text = await readFile(path, 'utf8').catch(() => '');
    // oxlint-disable-next-line no-await-in-loop
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  return text;
}

// The open dialog's title, once it is this
async function waitForDialog(page: Page, title: string): Promise<void> {
  await page.waitForFunction(
    (text) => [...document.querySelectorAll('dialog[open] h2')].some((heading) => heading.textContent === text),
    {},
    title,
  );
}

// Types into the cell and commits it with Enter
async function typeIn(page: Page, selector: string, text: string): Promise<void> {
  await page.click(selector);
  await page.keyboard.type(text);
  await page.keyboard.press('Enter');
}

async function showIn(page: Page, unit: string, waist: string): Promise<void> {
  await page.select('#show-in', unit);
  await page.waitForFunction(
    (text) => document.querySelector('#table tbody tr td:nth-child(2)')?.textContent === text,
    {},
    waist,
  );
}

// A catalogue measurement's view (0 front, 1 back, 2 side) and the first
// point of its line on the figure, from the catalogue's text
function overlayStart(text: string, key: string): [number, [number, number]] {
  const catalogue: unknown = JSON.parse(text);
  const entry = recordsField(isRecord(catalogue) ? catalogue : undefined, 'measurements').find(
    (each) => stringField(each, 'key') === key,
  );
  const overlay: unknown = entry?.overlay;
  const first: unknown = Array.isArray(overlay) ? (overlay as unknown[])[0] : undefined;
  const point = Array.isArray(first) ? (first as unknown[]) : [];
  const [x, y] = point;
  if (typeof x !== 'number' || typeof y !== 'number') {
    throw new Error(`the catalogue has no line for ${key}`);
  }
  return [['front', 'back', 'side'].indexOf(stringField(entry, 'view') ?? ''), [x, y]];
}

const folder = await mkdtemp(join(tmpdir(), 'opensloper-measurements-'));
const app = await serveApp({ root: 'out/measurements' });
const browser = await launchBrowser();
try {
  const page = await browser.newPage();
  // The table beside the side panel, as in a desktop browser window
  await page.setViewport({ width: 1200, height: 800 });
  const problems = watchProblems(page);
  await page.evaluateOnNewDocument(() => {
    Object.defineProperty(window, 'showOpenFilePicker', { value: undefined });
  });
  const session = await page.createCDPSession();
  await session.send('Browser.setDownloadBehavior', { behavior: 'allow', downloadPath: folder });
  await page.goto(`http://127.0.0.1:${String(app.port)}/`);
  await waitForData(page, 'ready', 'true');
  assert.equal(await page.title(), 'OpenSloper Measurements');
  assert.equal(await page.$('#table input[type=search]'), null, 'no search box before a set is open');
  assert.ok(
    await page.$eval('#set-name', (box) => box instanceof HTMLInputElement && box.disabled),
    'nothing to name before a set is open',
  );
  assert.match(await page.$eval('#table', (element) => element.textContent), /Open a measurement file/u);
  const input = await page.$('input#open-input');
  assert.ok(input);

  // A set without sizes: one Value column, in mm to start with
  await input.uploadFile(SET);
  await waitForStatus(page, 'Opened skirt.slm');
  await waitForRows(page, 4);
  assert.equal(await page.title(), 'skirt.slm — OpenSloper Measurements');
  assert.equal(await page.$eval('#set-name', (box) => (box instanceof HTMLInputElement ? box.value : '')), 'Tutorial');
  assert.ok(
    await page.$eval('#table .list-header', (header) => header instanceof HTMLElement && header.offsetHeight === 0),
    'the table has no search box',
  );
  let shown = await table(page);
  assert.deepEqual(shown.head, ['Key', 'Value', 'Description']);
  assert.deepEqual(shown.rows[0], ['waist', '660', 'Waist circumference']);
  await showIn(page, 'cm', '66');
  await showIn(page, 'in', '25.9843');
  await showIn(page, 'mm', '660');

  // Name and Notes: committed by Enter or by leaving the field, each one undo
  // step; Escape puts back the set's text
  async function fieldValue(id: string): Promise<string> {
    return page.$eval(id, (box) => (box instanceof HTMLInputElement ? box.value : ''));
  }
  await page.click('#set-name', { count: 3 });
  await page.keyboard.type('Anna');
  await page.keyboard.press('Enter');
  await waitForData(page, 'undo', 'Change name');
  assert.equal(await page.title(), '• skirt.slm — OpenSloper Measurements');
  await page.click('#set-notes', { count: 3 });
  await page.keyboard.type('Taken in June');
  await page.click(cellAt(2, 1));
  await waitForData(page, 'undo', 'Change notes');
  await page.click('#set-name', { count: 3 });
  await page.keyboard.type('Bea');
  await page.keyboard.press('Escape');
  assert.equal(await fieldValue('#set-name'), 'Anna');
  await press(page, 'Undo');
  await waitForData(page, 'undo', 'Change name');
  assert.equal(await fieldValue('#set-name'), 'Anna', 'Escape committed nothing');
  await press(page, 'Undo');
  await waitForData(page, 'undo', '');
  assert.equal(await fieldValue('#set-name'), 'Tutorial');

  // Add From the Catalogue: a group and a search, the entry's details, Add to
  // the file, and a value outside its typical range kept with a warning
  await page.waitForFunction(() => document.querySelectorAll('.catalogue option').length > 20);
  await page.select('.catalogue select:not([size])', 'circumferences');
  await page.type('.catalogue input[type=search]', 'under bust');
  await page.waitForFunction(() => document.querySelectorAll('.catalogue select[size] option').length === 1);
  await page.select('.catalogue select[size]', 'under_bust_circumference');
  await page.waitForFunction(() =>
    (document.querySelector('.catalogue-info')?.textContent ?? '').includes('Typically 650 to 1350 mm'),
  );
  await press(page, 'Add to the file');
  await waitForData(page, 'undo', 'Add measurement');
  assert.equal((await keys(page)).at(-1), 'under_bust_circumference');
  await page.waitForFunction(() => document.querySelectorAll('.catalogue select[size] option').length === 0);
  // The new row is chosen at its value, ready to type
  await page.keyboard.type('400');
  await page.keyboard.press('Enter');
  await waitForStatus(page, '@under_bust_circumference is outside the usual 650 to 1350 mm');
  await page.waitForSelector('#table td.warned');
  await press(page, 'Undo');
  await press(page, 'Undo');
  await waitForData(page, 'undo', '');
  await page.waitForFunction(() => document.querySelectorAll('.catalogue select[size] option').length === 1);

  // Check Against Pattern: what a pattern needs that the set lacks, under the
  // table; Add or go to it adds one; Stop Checking closes the list
  const patternInput = await page.$('input#pattern-input');
  assert.ok(patternInput);
  assert.equal(await page.$('.pattern-check:not([hidden])'), null, 'no check before a pattern is given');
  await patternInput.uploadFile(SET);
  await waitForStatus(page, 'skirt.slm is not a pattern file (.sloper)');
  await patternInput.uploadFile(PATTERN);
  await waitForStatus(page, 'Checking against skirt-darts.sloper');
  await page.waitForFunction(
    () =>
      document.querySelector('.pattern-check-summary')?.textContent ===
      'skirt-darts.sloper has everything it needs here',
  );
  await patternInput.uploadFile(BODICE);
  await page.waitForFunction(() => document.querySelectorAll('.pattern-check option').length === 8);
  assert.equal(
    await page.$eval('.pattern-check-summary', (summary) => summary.textContent),
    'bodice-block.sloper needs these, which this file cannot give it:',
  );
  // A pattern that cannot be read says so, and the check before stays
  const brokenPattern = join(folder, 'broken.sloper');
  await writeFile(brokenPattern, '{"format": "pattern"');
  await patternInput.uploadFile(brokenPattern);
  await waitForStatus(page, 'Could not read broken.sloper');
  assert.equal(
    await page.$eval('.pattern-check-summary', (summary) => summary.textContent),
    'bodice-block.sloper needs these, which this file cannot give it:',
  );
  assert.equal(await page.$$eval('.pattern-check option', (options) => options.length), 8);
  await page.select('.pattern-check select', 'across_back');
  await page.waitForFunction(() =>
    (document.querySelector('.catalogue-info')?.textContent ?? '').startsWith('Across back'),
  );
  await press(page, 'Add or go to it');
  await waitForData(page, 'undo', 'Add measurement');
  await page.waitForSelector('#table tr.selected[data-key="across_back"]');
  await page.waitForFunction(() => document.querySelectorAll('.pattern-check option').length === 7);
  await press(page, 'Stop Checking');
  await page.waitForSelector('.pattern-check', { hidden: true });
  await press(page, 'Undo');
  await waitForData(page, 'undo', '');

  // Edits in the grid, each one undo step
  assert.ok(
    await page.$eval(
      '#toolbar button:has(img[src="icons/arrow-back-up.svg"])',
      (button) => button instanceof HTMLButtonElement && button.disabled,
    ),
    'nothing to undo',
  );
  await typeIn(page, cellAt(1, 2), '680');
  await waitForData(page, 'undo', 'Change value');
  assert.equal(await page.title(), '• skirt.slm — OpenSloper Measurements');
  assert.equal(await page.$eval(cellAt(1, 2), (element) => element.textContent), '680');
  await typeIn(page, cellAt(1, 2), 'wide');
  await page.waitForSelector('#table td.refused');
  assert.equal(await status(page), 'A value must be a number, such as 82.5');
  // Escape on the reopened cell drops the refused text
  await page.keyboard.press('Enter');
  await page.keyboard.press('Escape');
  await page.waitForFunction(() => document.querySelector('#table td.refused') === null);
  await typeIn(page, cellAt(1, 1), 'waist_circumference');
  await waitForStatus(page, 'Renamed to @waist_circumference. Patterns using @waist');
  await waitForData(page, 'undo', 'Rename measurement');
  await typeIn(page, cellAt(1, 3), 'Round the natural waist');
  await waitForData(page, 'undo', 'Change description');
  // Add opens the new row's key to type; Up moves it; Delete asks first
  await press(page, 'Add');
  await page.waitForSelector('input.cell-editor');
  await page.keyboard.type('seat');
  await page.keyboard.press('Enter');
  await page.waitForSelector('#table tr[data-key="seat"]');
  assert.equal((await keys(page)).at(-1), 'seat');
  await press(page, 'Up');
  await waitForData(page, 'undo', 'Move measurement');
  assert.equal((await keys(page)).at(-2), 'seat', 'moved up, and still chosen');
  page.once('dialog', (dialog) => {
    void dialog.accept();
  });
  await press(page, 'Delete');
  await waitForData(page, 'undo', 'Delete measurement');
  assert.ok(!(await keys(page)).includes('seat'));
  await press(page, 'Undo');
  await waitForData(page, 'undo', 'Move measurement');
  assert.ok((await keys(page)).includes('seat'), 'undo brings it back');
  await press(page, 'Redo');
  await waitForData(page, 'undo', 'Delete measurement');

  // Opening another file asks before dropping the changes
  page.once('dialog', (dialog) => {
    void dialog.dismiss();
  });
  await input.uploadFile(SIZE_TABLE);
  await new Promise((resolve) => setTimeout(resolve, 300));
  assert.equal(await page.title(), '• skirt.slm — OpenSloper Measurements', 'kept when the user says no');
  page.once('dialog', (dialog) => {
    void dialog.accept();
  });

  // A size table: a column a size
  await input.uploadFile(SIZE_TABLE);
  await waitForData(page, 'undo', '');
  await waitForStatus(page, 'Opened size-table.slm');
  await waitForRows(page, 11);
  shown = await table(page);
  assert.deepEqual(shown.head, ['Key', '8', '10', '12', '14', '16', 'Description']);
  assert.deepEqual(shown.rows[0], [
    'bust_circumference',
    '820',
    '870',
    '920',
    '970',
    '1020',
    'Around the fullest part of the bust',
  ]);
  assert.equal(
    await page.$eval('#set-name', (box) => (box instanceof HTMLInputElement ? box.value : '')),
    "Women's sizes 8 to 16",
  );

  // The size buttons act on the column of the chosen cell, as on the desktop
  async function sizeButton(caption: string, enabled: boolean): Promise<void> {
    await page.waitForFunction(
      (text, on) =>
        [...document.querySelectorAll('#table-buttons button')].some(
          (button) => button instanceof HTMLButtonElement && button.textContent === text && button.disabled !== on,
        ),
      {},
      caption,
      enabled,
    );
  }
  async function head(expected: string[]): Promise<void> {
    await page.waitForFunction(
      (captions) => [...document.querySelectorAll('#table th')].map((cell) => cell.textContent).join() === captions,
      {},
      expected.join(),
    );
  }
  await sizeButton('Rename size…', false);
  await page.click(cellAt(1, 3));
  await sizeButton('Size left', true);
  await sizeButton('Size right', true);
  await page.click(cellAt(1, 1));
  await sizeButton('Rename size…', false);
  await page.click(cellAt(1, 3));
  page.once('dialog', (dialog) => {
    void dialog.accept('Ten');
  });
  await press(page, 'Rename size…');
  await head(['Key', '8', 'Ten', '12', '14', '16', 'Description']);
  assert.equal(await page.title(), '• size-table.slm — OpenSloper Measurements');
  await press(page, 'Size right');
  await head(['Key', '8', '12', 'Ten', '14', '16', 'Description']);
  assert.equal(await page.$eval(cellAt(1, 4), (element) => element.textContent), '870', 'the values go with it');
  assert.ok(
    await page.$eval(cellAt(1, 4), (element) => element.classList.contains('current')),
    'the chosen cell goes with it',
  );
  page.once('dialog', (dialog) => {
    void dialog.accept('12');
  });
  await press(page, 'Add size…');
  await waitForStatus(page, 'Size "12" is already in the table');
  page.once('dialog', (dialog) => {
    void dialog.accept('18');
  });
  await press(page, 'Add size…');
  await head(['Key', '8', '12', 'Ten', '14', '16', '18', 'Description']);
  assert.equal(await page.$eval(cellAt(1, 7), (element) => element.textContent), '', 'a new size has no values');
  page.once('dialog', (dialog) => {
    void dialog.accept();
  });
  await press(page, 'Delete size');
  await head(['Key', '8', '12', '14', '16', '18', 'Description']);
  await press(page, 'Undo');
  await waitForData(page, 'undo', 'Add size');
  await head(['Key', '8', '12', 'Ten', '14', '16', '18', 'Description']);

  // The body figure: a row under the pointer is highlighted on it, and a
  // click on a measurement's line chooses its row, as on the desktop
  await page.hover(cellAt(2, 1));
  await page.waitForSelector('.body-figure[data-highlight="waist_circumference"]');
  const figure = await page.$eval('.body-figure', (element) => ({
    width: element.clientWidth,
    height: element.clientHeight,
  }));
  const [view, onFigure] = overlayStart(
    await readFile('../data/measurement-catalogue.json', 'utf8'),
    'hip_circumference',
  );
  // As LayoutFigures in Sloper.Core.Catalogue, with the captions' room under it
  const room = figure.height - 19;
  const scale = Math.min(figure.width / 1500, room / 1000);
  const left = (figure.width - 1500 * scale) / 2 + view * 500 * scale;
  const top = (room - 1000 * scale) / 2;
  const box = await page.$eval('.body-figure', (element) => {
    const bounds = element.getBoundingClientRect();
    return { x: bounds.x + element.clientLeft, y: bounds.y + element.clientTop };
  });
  const x = box.x + left + onFigure[0] * scale;
  const y = box.y + top + onFigure[1] * scale;
  await page.mouse.move(x, y);
  await page.waitForFunction(() =>
    (document.querySelector('.catalogue-info')?.textContent ?? '').startsWith('Hip circumference'),
  );
  await page.waitForSelector('.body-figure[data-highlight="hip_circumference"]');
  await page.mouse.click(x, y);
  await page.waitForSelector('#table tr.selected[data-key="hip_circumference"]');

  // Refused: another kind of file, and one that cannot be read; the size table stays
  await input.uploadFile(PATTERN);
  await waitForStatus(page, 'skirt-darts.sloper is not a measurement file');
  const broken = join(folder, 'broken.slm');
  await writeFile(broken, '{"format": "measurements"');
  page.once('dialog', (dialog) => {
    void dialog.accept();
  });
  await input.uploadFile(broken);
  await waitForStatus(page, 'Could not open broken.slm');
  assert.equal(await page.title(), '• size-table.slm — OpenSloper Measurements');
  assert.equal((await table(page)).rows.length, 11);

  await press(page, 'Save');
  await waitForStatus(page, 'Downloaded size-table.slm');
  assert.equal(await page.title(), 'size-table.slm — OpenSloper Measurements');
  const downloaded = join(folder, 'size-table.slm');
  await page.waitForFunction(() => !document.title.startsWith('•'));
  assert.match(await readDownload(downloaded), /"18"/u);
  await input.uploadFile(downloaded);
  await waitForStatus(page, 'Opened size-table.slm');
  assert.equal((await table(page)).rows.length, 11);

  // Export…: the table's sizes are not Seamly2D's, so a multi-size file is
  // refused in the dialog; an individual file holds the chosen cell's size
  await page.click(cellAt(1, 2));
  await press(page, 'Export…');
  await waitForDialog(page, 'Export');
  await press(page, 'Export');
  await page.waitForFunction(() =>
    (document.querySelector('dialog[open] .seamly-refusal')?.textContent ?? '').startsWith(
      'Could not export size-table.smms: Size "',
    ),
  );
  await page.click('dialog[open] input[value="smis"]');
  await press(page, 'Export');
  await waitForStatus(page, 'Downloaded size-table.smis');
  await waitForDialog(page, 'Exported size-table.smis');
  await press(page, 'Close');
  const exported = await readDownload(join(folder, 'size-table.smis'));
  assert.match(exported, /<smis>/u);
  assert.match(exported, /name="waist_circ"/u);
  assert.equal(await page.title(), 'size-table.slm — OpenSloper Measurements', 'exporting leaves the set');

  // Import…: only their files, and one read becomes a new set named after
  // it, not saved, with a report of what changed
  const importInput = await page.$('input#import-input');
  assert.ok(importInput);
  await importInput.uploadFile(PATTERN);
  await waitForStatus(page, 'skirt-darts.sloper is not a Seamly2D or Valentina measurement file');
  await importInput.uploadFile(join(folder, 'size-table.smis'));
  await waitForStatus(page, 'Imported size-table.smis');
  await waitForDialog(page, 'Imported size-table.smis');
  assert.match(await page.$eval('dialog[open] textarea', (report) => report.value), /measurements read/u);
  await press(page, 'Close');
  assert.equal(await page.title(), '• size-table.slm — OpenSloper Measurements');
  assert.equal((await table(page)).head.length, 3, 'one size: a single Value column');
  assert.ok((await keys(page)).includes('waist_circumference'));

  // SCREENSHOT names a PNG file to keep what the page shows at the end
  if ((process.env.SCREENSHOT ?? '') !== '') {
    await page.screenshot({ path: `${process.env.SCREENSHOT ?? ''}.png` });
  }
  assert.deepEqual(problems, []);
  console.log('Measurements app passed');
} finally {
  await browser.close();
  app.close();
  await rm(folder, { recursive: true, force: true });
}
