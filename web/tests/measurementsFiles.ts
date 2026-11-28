// Opens, saves and recovers a measurement set through the same file handles
// the browser's local pickers give, with the pickers stood in for over OPFS.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import type { Page } from 'puppeteer-core';
import {
  launchBrowser,
  pressWithMod,
  queuePicks,
  readOpfs,
  serveApp,
  standInPickers,
  waitForData,
  waitForStatus,
  watchProblems,
  writeOpfs,
} from './browser.ts';

const ORIGINAL = 'sets/skirt.slm';
const COPY = 'sets/skirt-copy.slm';
const VALUE = '#table tbody tr[data-key="waist"] td:nth-child(2)';

async function typeValue(page: Page, value: string): Promise<void> {
  await page.click(VALUE);
  await page.keyboard.type(value);
  await page.waitForSelector(`${VALUE} .cell-editor`);
}

const app = await serveApp({ root: 'out/measurements' });
const browser = await launchBrowser();
const url = `http://127.0.0.1:${String(app.port)}/`;

async function openTab(): Promise<Page> {
  const page = await browser.newPage();
  await page.setViewport({ width: 1200, height: 800 });
  await page.evaluateOnNewDocument(standInPickers);
  await page.goto(url);
  await waitForData(page, 'ready', 'true');
  return page;
}

try {
  const page = await openTab();
  const problems = watchProblems(page);
  await waitForData(page, 'offline', 'true');
  const original = await readFile('../docs/examples/skirt-block/skirt.slm', 'utf8');
  await writeOpfs(page, ORIGINAL, original);
  await queuePicks(page, ORIGINAL);
  await pressWithMod(page, 'o');
  await waitForStatus(page, 'Opened skirt.slm');

  // The Save shortcut commits the cell still being edited.
  await typeValue(page, '687');
  await pressWithMod(page, 's');
  await waitForStatus(page, 'Saved skirt.slm');
  const saved = await readOpfs(page, ORIGINAL);
  assert.match(saved, /"value": 687/u);
  assert.equal(await page.title(), 'skirt.slm — OpenSloper Measurements');
  // Undo and redo still know which text was last written.
  await page.click('#toolbar button:has(img[src="icons/arrow-back-up.svg"])');
  await page.waitForFunction(() => document.title.startsWith('•'));
  await page.click('#toolbar button:has(img[src="icons/arrow-forward-up.svg"])');
  await page.waitForFunction(() => !document.title.startsWith('•'));

  await typeValue(page, 'wide');
  await pressWithMod(page, 's');
  await waitForStatus(page, 'Correct or dismiss the refused cell edits before saving');
  assert.equal(await readOpfs(page, ORIGINAL), saved);
  await typeValue(page, '689');
  await page.keyboard.press('Enter');
  await waitForData(page, 'undo', 'Change value');
  // Changes written by someone else must survive an in-place save.
  const external = saved.replace('"value": 687', '"value": 688');
  await writeOpfs(page, ORIGINAL, external);
  await pressWithMod(page, 's');
  await waitForStatus(page, 'skirt.slm changed on disk');
  assert.equal(await readOpfs(page, ORIGINAL), external);
  assert.match(await page.title(), /^•/u);

  await queuePicks(page, COPY);
  await page.click('#toolbar button[title^="Save the measurement set to another file"]');
  await waitForStatus(page, 'Saved skirt-copy.slm');
  assert.match(await readOpfs(page, COPY), /"value": 689/u);
  await typeValue(page, '691');
  await page.keyboard.press('Enter');
  await waitForData(page, 'workKept', 'true');

  // The service worker serves the app offline. Recovered work still saves
  // to the handle from Save As.
  app.close();
  await page.close();
  const recovered = await openTab();
  const recoveredProblems = watchProblems(recovered);
  await waitForStatus(recovered, 'Unsaved work on skirt-copy.slm');
  await recovered.click('#message button');
  await waitForStatus(recovered, 'Opened the unsaved work on skirt-copy.slm');
  assert.equal(await recovered.title(), '• skirt-copy.slm — OpenSloper Measurements');
  assert.equal(await recovered.$eval(VALUE, (cell) => cell.textContent), '691');
  await pressWithMod(recovered, 's');
  await waitForStatus(recovered, 'Saved skirt-copy.slm');
  await waitForData(recovered, 'workKept', 'false');
  assert.match(await readOpfs(recovered, COPY), /"value": 691/u);
  assert.deepEqual(problems.concat(recoveredProblems), []);
  console.log('Measurements files and offline use passed');
} finally {
  await browser.close();
  app.close();
}
