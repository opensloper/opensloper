// Bundles the web pages with esbuild, each with the engine's worker, and
// copies what they load beside them: the design app into out/design, with the
// toolbar icons and the example patterns of the user guide, the publish and
// measurements apps, with their examples, into out/publish and
// out/measurements, and the spike's
// page into engine/out/browser. The engine
// (engine_lib.wasm) is built first by ./opensloper-make.sh web. Each app's
// folder ends with its manifest and its service worker (sw.js), given the list
// of every other file and a version made from their contents, so it can keep
// them for offline use and a new build installs a new one. Node runs this
// TypeScript as it is.
import { createHash } from 'node:crypto';
import { access, copyFile, cp, mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises';
import { dirname, join, relative, sep } from 'node:path';
import { build } from 'esbuild';
import { MEASUREMENT_EXAMPLES } from './src/measurements/examples.ts';
import { PUBLISH_EXAMPLES } from './src/publish/examples.ts';

const ENGINE = 'engine/out/browser/engine_lib.wasm';
const DESIGN = 'out/design';
const PUBLISH = 'out/publish';
const MEASUREMENTS = 'out/measurements';
const SERVICE_WORKER = 'sw.js';

// What the browser needs to offer to install an app; icon is the name of
// its icons (resources/opensloper-design.svg and resources/web's PNGs)
function manifest(name: string, description: string, icon: string): object {
  return {
    name,
    short_name: name,
    description,
    start_url: '.',
    scope: '.',
    display: 'standalone',
    background_color: '#f2f1ed',
    theme_color: '#f2f1ed',
    icons: [
      { src: `${icon}.svg`, sizes: 'any', type: 'image/svg+xml' },
      { src: `${icon}-192.png`, sizes: '192x192', type: 'image/png' },
      { src: `${icon}-512.png`, sizes: '512x512', type: 'image/png' },
    ],
  };
}

// The app's icons and manifest, then its service worker, which keeps every
// other file of the folder, under a version that changes when any of them does
async function installable(folder: string, app: string, about: object, icon: string): Promise<void> {
  await copyFile(`../resources/${icon}.svg`, join(folder, `${icon}.svg`));
  for (const size of [192, 512]) {
    // oxlint-disable-next-line no-await-in-loop
    await copyFile(`../resources/web/${icon}-${String(size)}.png`, join(folder, `${icon}-${String(size)}.png`));
  }
  await writeFile(join(folder, 'manifest.webmanifest'), `${JSON.stringify(about, undefined, 2)}\n`);
  // Every file of the app, with / between folders as URLs have them
  const files = (await readdir(folder, { recursive: true, withFileTypes: true }))
    .filter((entry) => entry.isFile())
    .map((entry) => relative(folder, join(entry.parentPath, entry.name)).split(sep).join('/'))
    .filter((file) => file !== SERVICE_WORKER)
    // A new array from filter, sorted so the version does not hang on the order files are read in
    // oxlint-disable-next-line unicorn/no-array-sort
    .sort();
  const hash = createHash('sha256');
  for (const file of files) {
    hash.update(file);
    // oxlint-disable-next-line no-await-in-loop
    hash.update(await readFile(join(folder, file)));
  }
  await build({
    entryPoints: ['src/ui/serviceWorker.ts'],
    bundle: true,
    format: 'iife',
    target: 'es2022',
    outfile: join(folder, SERVICE_WORKER),
    define: {
      SW_APP: JSON.stringify(app),
      SW_FILES: JSON.stringify(files),
      SW_VERSION: JSON.stringify(hash.digest('hex').slice(0, 16)),
    },
    logLevel: 'warning',
  });
}

// The examples named, from docs/examples into the app's examples folder, at the same places
async function copyExamples(folder: string, paths: Iterable<string>): Promise<void> {
  await Promise.all(
    [...paths].map(async (path) => {
      const target = join(folder, 'examples', path);
      await mkdir(dirname(target), { recursive: true });
      await copyFile(join('../docs/examples', path), target);
    }),
  );
}

async function bundle(entries: string[], outdir: string): Promise<void> {
  await build({
    entryPoints: entries,
    bundle: true,
    format: 'esm',
    target: 'es2022',
    outdir,
    entryNames: '[name]',
    logLevel: 'warning',
  });
}

try {
  await access(ENGINE);
} catch {
  console.error(`No ${ENGINE}: build the engine first with ./opensloper-make.sh web`);
  process.exit(2);
}

// A clean folder, so the service worker keeps no file an older build left
await rm(DESIGN, { recursive: true, force: true });
await mkdir(DESIGN, { recursive: true });
await bundle(['src/design/main.ts', 'src/engine/worker.ts'], 'out/design');
await copyFile('src/design/index.html', 'out/design/index.html');
await copyFile('src/ui/sidePanel.css', 'out/design/sidePanel.css');
await copyFile('src/ui/listPanel.css', 'out/design/listPanel.css');
await copyFile('src/ui/printDialog.css', 'out/design/printDialog.css');
await copyFile(ENGINE, 'out/design/engine_lib.wasm');
await cp('../data/icons', 'out/design/icons', { recursive: true });
// Patterns and measurement files, laid out as in the guide so each finds its
// measurement file. Drape and layout files belong to the other apps.
await cp('../docs/examples', 'out/design/examples', {
  recursive: true,
  filter: (source) => !source.endsWith('.sdrape') && !source.endsWith('.slayout'),
});
await installable(
  DESIGN,
  'design',
  manifest('OpenSloper', 'Parametric sewing pattern drafting', 'opensloper-design'),
  'opensloper-design',
);

// The Publish app, its own page with the same engine
await rm(PUBLISH, { recursive: true, force: true });
await mkdir(PUBLISH, { recursive: true });
await bundle(['src/publish/main.ts', 'src/engine/worker.ts'], PUBLISH);
await copyFile('src/publish/index.html', join(PUBLISH, 'index.html'));
await copyFile('src/ui/sidePanel.css', join(PUBLISH, 'sidePanel.css'));
await copyFile('src/ui/printDialog.css', join(PUBLISH, 'printDialog.css'));
await copyFile(ENGINE, join(PUBLISH, 'engine_lib.wasm'));
await cp('../data/icons', join(PUBLISH, 'icons'), { recursive: true });
const publishExampleFiles = new Set(PUBLISH_EXAMPLES.flatMap(({ layout, sources }) => sources.concat(layout)));
await copyExamples(PUBLISH, publishExampleFiles);
await installable(
  PUBLISH,
  'publish',
  manifest('OpenSloper Publish', 'Print sewing patterns at true size, tiled or on one sheet', 'opensloper-publish'),
  'opensloper-publish',
);

// The Measurements app, its own page with the same engine
await rm(MEASUREMENTS, { recursive: true, force: true });
await mkdir(MEASUREMENTS, { recursive: true });
await bundle(['src/measurements/main.ts', 'src/engine/worker.ts'], MEASUREMENTS);
await copyFile('src/measurements/index.html', join(MEASUREMENTS, 'index.html'));
await copyFile('src/ui/listPanel.css', join(MEASUREMENTS, 'listPanel.css'));
await copyFile(ENGINE, join(MEASUREMENTS, 'engine_lib.wasm'));
await cp('../data/icons', join(MEASUREMENTS, 'icons'), { recursive: true });
// The catalogue the page gives the engine, beside it, as Ni-zav's #111 served it
await copyFile('../data/measurement-catalogue.json', join(MEASUREMENTS, 'measurement-catalogue.json'));
await copyExamples(
  MEASUREMENTS,
  MEASUREMENT_EXAMPLES.map(({ path }) => path),
);
await installable(
  MEASUREMENTS,
  'measurements',
  manifest('OpenSloper Measurements', 'Measurement sets and size tables', 'opensloper-measure'),
  'opensloper-measure',
);

await bundle(['engine/browser/main.ts', 'src/engine/worker.ts'], 'engine/out/browser');
await copyFile('engine/browser/index.html', 'engine/out/browser/index.html');
console.log('Bundled out/design, out/publish, out/measurements and engine/out/browser');
