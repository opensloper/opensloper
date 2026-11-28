# The web version

The web Design app (issue #78), Publish app (issue #85) and Measurements
app (issue #84), as `documents/design/web-version.md` describes them.

- The engine is the Pascal core compiled to WebAssembly (`engine/`). It runs in a Web Worker.
- The editor on top of it is plain TypeScript.
- Files stay on the user's machine. The page opens and saves them as text and sends nothing anywhere.

| Folder              | What it is                                                                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `engine/`           | The engine's Wasm build and the spike's timing page (`engine/README.md`)                                                                                     |
| `src/engine/`       | The worker that runs the engine, and `Engine`, which calls it                                                                                                |
| `src/document/`     | `PatternDocument`, the open pattern, as the desktop's `TPatternDocument`; `LayoutDocument`, the open layout; `MeasurementDocument`, the open measurement set |
| `src/editor/`       | Copies of Pascal logic run on every frame (`view.ts`, `labelPlacement.ts`), and the engine's scene and tables, typed                                         |
| `src/ui/`           | The canvas, its painter and tools, side tabs, list panels, the properties panel, shortcuts and strings, named after their `src/ui` units                     |
| `src/design/`       | The Design app's page and `main.ts`, as `Sloper.Design.MainForm`                                                                                             |
| `src/publish/`      | The Publish app's page and `main.ts`, as `Sloper.Publish.MainForm`                                                                                           |
| `src/measurements/` | The Measurements app's page, `main.ts` as `Sloper.Measurements.MainForm`, and its table (`measurementGrid.ts`)                                               |
| `tests/`            | Unit tests (`*.test.ts`, run with `node --test`) and the browser tests (see below); `browser.ts` serves the apps for them                                    |
| `bundle.ts`         | Bundles the pages with esbuild into `out/design`, `out/publish`, `out/measurements` and `engine/out/browser`                                                 |

## The Design app

Built into `out/design`.

- **The canvas** draws pieces, edges, seams, notes, callouts, markers, points and labels.
  - The wheel zooms and the middle button pans. Rulers and a grid in the pattern's unit can be shown.
  - Click or box to select. A drag of a point, note, curve handle or callout tip is one undo step.
- **Every drawing tool** of the desktop's: Point, Line, Curve, Circle, Rectangle, Piece, Notch, Seam, Text and Callout.
- **The toolbar** has Open, Measurements, Save, Save as, Undo, Redo, Fit, Examples, Print, Export SVG, Import SVG Stamp, the role box, the labels mode, rulers and the _Change point to…_ box.
- **Editing** has cut, copy, paste and Delete.
- **The side panel**, as the desktop's:

  | Tab          | What it does                                                                                                               |
  | ------------ | -------------------------------------------------------------------------------------------------------------------------- |
  | Properties   | The selected object's rows, from the engine: formulas with completion and suggestions, choices, boxes, numbers and colours |
  | Objects      | Searchable; follows the canvas selection and sets it                                                                       |
  | Variables    | Edited in the grid, with name completion; Import… takes them from another pattern                                          |
  | Measurements | Edited in the grid, in bold until Save writes the file; the size box and the test size                                     |
  | Features     | Zips, darts, hems, facings and buttons                                                                                     |
  | Materials    | The pattern's materials                                                                                                    |
  | Garment      | The pieces as sewn                                                                                                         |
  | Problems     | At the foot; click a problem to go to it                                                                                   |

## The Publish app

Built into `out/publish`.

- **Open** takes a layout with its patterns and measurement files, or patterns to start one.
- **The preview** shows the pages, pieces and notes.
  - Pieces and notes are dragged, turned and placed from the tray.
  - A right-click leaves a page out.
- **The side panel** has the desktop's tabs but Claude's: Patterns, Pieces, Materials, Information Block, Notes, Output and Problems.
- **Print** goes through the browser. Export writes PDF, SVG and DXF-AAMA. Machine DXF stays on the desktop.
- **The keys** are the desktop's.

## The Measurements app

Built into `out/measurements`, step by step (`documents/design/open-items.md`).

- **Open** takes a measurement set or size table (`.slm`). **Undo** and **Redo** take back each change.
- **Name and Notes** are above the table, read only for now.
- **The table** has a row a measurement: its key, a value column a size, or one Value column, and its description. Every cell is edited in the grid. **Add**, **Delete**, **Up** and **Down** are over it.
- **Show in** chooses mm, cm or inches.

## The Design and Publish apps

- **File System Access**, in Chrome and Edge, saves files in place. It also finds a pattern's measurement file, or a layout's patterns, in a folder granted once. Other browsers upload and download files.
- **Work not yet saved** is kept in the browser (OPFS). It is offered back after the tab that had it closes.
- **A service worker** keeps each app for offline use and installing. An Update button shows when a new build is ready.

## Setting up

Node and npm come from the repository's Python `venv`, through `nodeenv`. Nothing is installed system-wide:

```
./venv/bin/pip install nodeenv
source venv/bin/activate && nodeenv -p --prebuilt --node=lts
cd web && npm ci
```

## Building and running

From the repository's root:

```
./opensloper-make.sh web               # the engine, then npm run build: check, unit tests, bundle
./opensloper-make.sh site --serve      # the apps in the Django site, at 127.0.0.1:8000/design/, /publish/ and /measurements/
```

Or serve one app on its own:

```
python3 -m http.server 8766 --bind 127.0.0.1 --directory web/out/design    # http://127.0.0.1:8766/
python3 -m http.server 8767 --bind 127.0.0.1 --directory web/out/publish   # http://127.0.0.1:8767/
python3 -m http.server 8768 --bind 127.0.0.1 --directory web/out/measurements   # http://127.0.0.1:8768/
```

- Serve the app over HTTP. Its module worker does not load from `file://`.
- The service worker keeps answering from the build it has. After rebuilding, click Update, or clear it in the browser's developer tools.
- In Design, open a `.sloper` file and choose its measurement file with it, or later with Measurements….
- In Publish, open a `.slayout` with its patterns, or a pattern with its measurement file.
- In Measurements, open a `.slm`, such as `docs/examples/measurements/size-table.slm`.

## Testing

```
(cd web && npm run test:browser)   # the apps in headless Chromium; SCREENSHOT=name keeps name.png
```

- The browser tests are `design.ts`, `files.ts`, `offline.ts`, `publish.ts`, `publishFiles.ts`, `publishOffline.ts` and `measurements.ts`.
- They use `/usr/bin/chromium` on Linux and Google Chrome in `/Applications` on macOS. Set `CHROMIUM` to use another browser.
- If `npm` is not found, put the `venv` on the path first: `export PATH=$PWD/../venv/bin:$PATH`.

`npm run check` runs `tsc`, Oxlint and Prettier, as the TypeScript section of `documents/coding-standards.md` describes. `npm run format` lays the files out. `./opensloper-make.sh check` and `format` run them too.
