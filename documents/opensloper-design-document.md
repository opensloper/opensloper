# OpenSloper — Design Document

The design of OpenSloper and the reasons behind it. This file covers what every app shares; each app and the Automation API have a file of their own in `documents/design/`. The files describe what is built and the decisions behind it; what is not built yet is in [Open items](design/open-items.md). When a design decision changes, change the file it belongs to in the same commit.

| File | What it covers |
| --- | --- |
| This file | Overview, architecture, files, preferences, platforms and releases, dependencies, testing, documentation, translation, privacy |
| [Measurements app](design/measurements-app.md) | Measurement files and size tables, the catalogue, other programs' formats |
| [Design app](design/design-app.md) | Evaluator, names and IDs, formulas, units, operations, the canvas, markings, seams, materials, notes, accessories, features, the Garment tab |
| [Publish app](design/publish-app.md) | Layouts, printing, output profiles, exports, cutting machines, material needed |
| [Drape app](design/drape-app.md) | Placing pieces round a body in 3D and draping them in Blender |
| [Automation API and command line](design/automation-api.md) | The CLI, the JSON-RPC API, MCP, live editing, the Claude tabs, safety, PNG drawing |
| [Web version](design/web-version.md) | The planned browser version: the engine in WebAssembly, a TypeScript editor, a Django server |
| [Open items](design/open-items.md) | Roadmap, to do, open questions and future ideas |

## Overview

OpenSloper is a parametric sewing pattern drafting application written in Lazarus/Free Pascal. It owes much to Valentina and Seamly2D, the open source parametric pattern programs whose ideas it builds on. Patterns are drafted with relative distances and formulas, so changing a measurement redraws the whole pattern. Valentina and Seamly2D do this already, but both are large and have a steep learning curve; OpenSloper aims for the same parametric power with a simpler, more direct drawing experience.

Goals:

- Parametric drafting driven by measurement sets and variables
- An Inkscape-like canvas where snapping records relationships automatically
- Automatic piece detection instead of tracing outlines in order
- Seam allowance, notches, grainlines and true-scale tiled printing
- Garments and accessories in fabric and leather, with output for cutting machines
- A small, maintainable codebase with a pure-Pascal core, built from what comes with the compiler

## Technology and licence

Lazarus/Free Pascal, licensed GPLv3 or later, matching Valentina and Seamly2D so code can be studied, borrowed and shared in both directions. `LICENSE` holds the full text and every unit starts with the GPL header; code translated from Valentina or Seamly2D keeps their copyright line. The About box shows the licence and no-warranty notice. The user documentation is CC BY-SA 4.0.

**Why Pascal.**

- **Everything comes with the compiler.** FCL and LCL cover the GUI, JSON, XML, file handling and testing (FPCUnit), so the project needs only three small packages (see Dependencies). TypeScript, Java or Rust would pull in hundreds of packages, each able to change, break the build or be withdrawn.
- **It will still build in ten years.** Free Pascal changes slowly and keeps old code compiling. Patterns are kept for years, so the program that opens them has to outlast fashions in tooling.
- **Native apps from one toolkit.** The LCL draws with each platform's own widgets (Qt on Linux, Cocoa on macOS, Win32 on Windows), giving one native executable per app with no runtime or browser engine to ship.
- **Fast to build and run.** The whole project builds in seconds, and compiled code re-evaluates a pattern on every drag.
- **Readable**, which suits code meant to be studied and borrowed, including by contributors who are not full-time programmers.
- **Reaches the web too.** Free Pascal compiles to WebAssembly, so the same core can run in a browser (see [Web version](design/web-version.md)).

The cost: fewer developers than C++, TypeScript or Rust; more code written by hand; and manual memory management, kept in order by the coding standards (`FreeAndNil`, `try`/`finally`) and heaptrc leak checks in the tests.

## Core concepts

A pattern is a graph of draft objects whose positions come from measurements, variables and other objects.

| Concept | What it is | Notes |
| --- | --- | --- |
| Measurement set | A person's or product's measurements, e.g. `@waist` | Own file, edited in the measurements app; one set drives many patterns. One person's set or a size table |
| Variable | Pattern-level value, e.g. `#ease_waist = 20` | Design decisions; formulas may use measurements and other variables, not draft objects |
| Point | A position defined by an operation, its references and formulas | Never stored as fixed coordinates, except free points |
| Operation | How an object is placed: offset, along an edge, intersection, transform… | Inferred from snapping where possible; listed on the generated Operations page |
| Edge | Line, curve, path, circle, arc or offset between points | Curve handles have angle and length formulas |
| Role | Construction, outline, or a marking role (placement, stitch, fold, cut, skive, edge finish) | Only outline edges form piece boundaries |
| Marker | A point's mark: plain, hole, button or match dot | A marked point inside a piece prints with it |
| Piece | Closed path of edge references, each with a reversed flag | Allowance, grainline, notches, markings, material, cut count, fold |
| Material | A named material (Main, Lining, Leather) with a colour and fill | Piece fills, the cut list, fit checks, material layouts, drape fabric |
| Seam | The edges sewn together, with direction and expected ease | Seam-length checks, the Garment tab's darts, sewing in Blender |
| Layout | Pieces arranged on sheets for printing, plotting or cutting | Works on computed geometry only |
| Drape | Pieces placed round a body in 3D | Exported to Blender's cloth simulation |
| Annotation | Note, callout, stamp, information block or sheet note | Anchored to objects by ID; may contain live fields |

## Architecture

Four layers, each depending only on the ones below. The core has no LCL dependency, so it is unit-tested without a UI and shared by the CLI and the planned web version.

- **UI (LCL):** canvas, interaction tools, snapping, panels
- **Output:** PDF, SVG, DXF, the Blender export and PNG drawing; reads computed geometry only
- **Document:** `TPatternDocument` and the other documents, undo/redo, change notifications
- **Core (pure Pascal):** geometry, formulas, model, evaluator, pieces (Clipper2 seam allowance), storage

Four GUI apps sit on these layers: measurements, design, publish and drape. Each owns one kind of file and only reads the ones before it (measurements → patterns → layouts and drapes), so nothing is synchronised back. They share the core and output layers, not each other's UI. The UI changes the model only through document commands, and exporters read computed geometry from the core, so a new output format never touches drafting code. The Automation API depends only on the document, core and output layers.

## Key design decisions

The central rule: only definitions are saved and undone; computed geometry is always derived.

1. **Definition vs result.** Each object holds its definition (operation, references, formula strings) and a cached computed result. Saving, loading and undo touch definitions only.
2. **Dependencies come from formulas.** Each formula is parsed once into an expression tree; its references plus the operation's direct inputs form the dependency graph, which the user never manages.
3. **Ordered evaluation.** The graph is sorted topologically and evaluated in order. An edit that would make a cycle is refused.
4. **Failures are states, not crashes.** An object that cannot be evaluated and its dependents become invalid and show in red; the pattern stays editable.
5. **IDs separate from names.** IDs are integers that never change and are never reused; names can change freely.
6. **One class per operation.** Each operation declares its inputs and formulas and evaluates itself. Adding one means the class, its `Add…` call on `TPattern`, its file type in `Sloper.Core.PatternFile` and its row in `Sloper.Core.OperationInfo`.
7. **Commands for undo.** Every user change is one step; one drag is one step (live during the drag, committed on release, Escape cancels). Nudges of one object within a second merge, as do runs of changes to one field; formula fields commit on Enter or leaving. A document keeps each step as the file's text before and after (`BeginChange`, `EndChange`, `CancelChange`), so undo restores exactly the earlier definitions with the same IDs and needs no inverse per edit. Undo replaces objects with new instances, so the UI holds objects by ID, never by reference. A step the file was saved after is never merged into; at most 500 steps are kept; the ID counter only goes up, even on undo. The measurement set chosen belongs to the document, not the history.
8. **Storage apart from the model.** `TPattern` knows nothing about JSON; `Sloper.Core.PatternFile` reads and writes it.

## Files

Patterns (`.sloper`), measurements (`.slm`), layouts (`.slayout`) and drapes (`.sdrape`) are JSON: built into FCL, readable, diffable in git, easy to share. Seamly2D and Valentina measurement files are XML; exports are SVG, DXF, PDF, OBJ and PNG.

**Rules** (`Sloper.Core.JSON`):

- `format` and `version` at the top of every file; a program refuses a version newer than it knows, or below 1.
- Every object has a stable ID and is referenced by it. Formulas are stored in ID form and parsed on load. A pattern's `units` is the unit of its formula numbers; measurement, layout and drape files store mm.
- Fixed member order and layout on save: two-space indent, LF, numbers in the shortest form that reads back exactly, `.` as decimal point, UTF-8.
- A file that fails to load says why and leaves nothing half-loaded; a formula that does not parse is kept as text and shows as an error.
- Files come from other people, so nothing in one may crash the program: nesting past 256 levels is refused before parsing, and a number past a double's range (`1e400`) is refused (`TextToFiniteFloat`).
- Files are written atomically (a temporary file beside it, then a rename, `WriteTextFileAtomic`), so an interrupted save leaves the old file whole and another app never reads half of one.

**Format versions.** While nobody uses the files yet, formats are changed in place and every format stays at version 1. Once files are in use, a change raises the version: each format keeps one reader for its current version, and `Sloper.Core.FileVersions` brings an older file up to it by upgrade steps on its parsed JSON (`UpgradeFile`), one step per version. Files are always written at the current version, so opening and saving upgrades them. Raising a version needs the step, an old file in `tests/files/v<n>/` and a test. The settings, recent files, clipboard fragment and catalogue only refuse a newer version.

**The formats are specified in the user documentation**, so Claude and other tools can rely on them. `opensloper-cli doc files` writes the File formats page and `opensloper-cli doc pattern.schema.json` (also `measurements`, `layout`, `drape` and `blender`) a JSON Schema for each, from code tables (`Sloper.Core.FileInfo`, `Sloper.Core.OperationInfo`). A schema lists exactly the members the apps write, marks the required ones and allows no others. Tests hold the tables to the writers both ways, and `check-schemas.py` checks every example and regression file against the schemas.

**Pattern file rules** the schema cannot say:

- `variables` and `objects` are in creation order, and an object's direct inputs come earlier in the file. Formulas may refer to any ID; a missing one is an error when evaluated. A piece that takes on a newer point moves to the end.
- An edge named after its ends has no `name`; it is worked out on load.
- `nextId` is above every ID and is written as it stands, so deleted IDs stay retired. A hand-written file may leave it out, and members at their defaults.
- `materials` comes after `objects` but is read first; a pattern whose only material is the untouched Main writes neither `materials` nor a piece `material`.
- `measurementFile` is relative to the pattern's folder unless absolute, with `/` separators. The size used from a size table is not saved.
- Loading checks IDs (positive, unique, below `nextId`), names, types and inputs, failing with the object's ID (`Object 6 uses object 9, which is not defined before it`).
- `view` holds view state (zoom, hidden roles, `hiddenPieces`, `isolate`, `pieceOrder`), kept out of undo.

## Preferences

Edit → Preferences… opens the same dialog in every app (`Sloper.UI.Preferences`), on the app's own tab; OK saves `settings.json` (`TPreferences` in `Sloper.Core.Settings`). The apps already open pick the change up at once: the app that saved sends a `preferences` notification over the apps' link (see [Finding an open window](design/publish-app.md#finding-an-open-window)) and each reads the file again. The file stays the one source; a window that misses the message reads it at its next start.

| Tab | Setting | Stored as |
| --- | --- | --- |
| General | Unit (mm, cm, in) for new patterns and the measurements app's display; never changes an existing pattern | `measureUnit` |
| General | Anthropic API key (kept in its own file) and whether assistants may read measurements | `assistantMeasurements` |
| Design | Grid spacing per unit, in that unit's own numbers (5 mm, 0.5 cm, ⅛ in) | `gridSteps` |
| Design | Garment tab shading, light direction and strength | `garmentShading`, `garmentLightAngle`, `garmentShadeStrength` |
| Publish | Printer calibration across and down (0.5 to 2), with Work Out Factors from a measured test square | `calibrationX`, `calibrationY` |
| Drape | Blender program, mesh spacing (2–100 mm), frames (1–10000) | `blenderProgram`, `drapeSpacing`, `drapeFrames` |

Calibration belongs to the printer, not the layout, so layouts do not carry it.

## File locations

OpenSloper follows each platform's conventions and never writes app files into the home folder root.

| Kind | Examples | Linux (XDG) | Windows | macOS |
| --- | --- | --- | --- | --- |
| Config | `settings.json`, `anthropic-key` | `~/.config/opensloper/` | `%APPDATA%\OpenSloper\` | `~/Library/Application Support/OpenSloper/` |
| Data | Not used yet | `~/.local/share/opensloper/` | `%APPDATA%\OpenSloper\` | `~/Library/Application Support/OpenSloper/` |
| State | `recent-files.json`, logs | `~/.local/state/opensloper/` | `%LOCALAPPDATA%\OpenSloper\` | `~/Library/Application Support/OpenSloper/` |
| Cache | Thumbnails, previews | `~/.cache/opensloper/` | `%LOCALAPPDATA%\OpenSloper\Cache\` | `~/Library/Caches/OpenSloper/` |

`XDG_*_HOME` is respected. What the programs read ships in `data/` beside them (one folder up in the source tree, `Contents/Resources` in the macOS bundle): the catalogue, body figures, icons, fonts, the Blender script and, in downloads, the offline user guide in `data/help` (Help → User Guide opens the website without it). Folders are made on first use. User documents default to `Documents/OpenSloper/` on first save, then the last folder used.

**Portable install.** An empty `portable.ini` beside the programs (beside `OpenSloper.app` on macOS) puts everything the apps write in `user/` beside it, and first saves in `documents/`, so a USB stick leaves nothing on the computer. Recent files inside the portable folder are kept relative to it. The runtime folder (sockets) is never portable. `TAppPaths.PortableRoot` gives the folder.

**Implementation.** `TAppPaths` gives every folder; no other code builds these paths. The apps share `settings.json` and `recent-files.json`, so every save reads the file again first and changes only its own part. An unreadable settings file leaves the defaults and saving over it is refused. File → Open Recent lists each app's last 10 files (`Sloper.Core.RecentFiles`).

## Platforms

| Platform | Role | Widgetset | Notes |
| --- | --- | --- | --- |
| Linux | Main development | Qt5 or Qt6 | Needs the `libQt5Pas` or `libQt6Pas` bindings |
| macOS | Testing | Cocoa | Apple Silicon, `.app` bundle |
| Windows | Release builds | Win32 | Built by the release workflow |

**Keeping all platforms viable:** shortcuts use `ssModifier` (Cmd on macOS, Ctrl elsewhere), written `Mod` in `Sloper.Core.Shortcuts`; a key macOS keeps for itself (Cmd+Tab) is written `Ctrl` and is the Control key everywhere. Paths go through `TAppPaths` with `ConcatPaths` and `PathDelim`; no Unix-only units in the core; widgetset-specific code is behind `{$IFDEF}` with a do-nothing fallback.

**App icons.** The SVGs in `resources/` are the masters; `resources/make-icons.sh` makes each app's committed `.ico`.

**Release builds.** Every push to `release` runs `.github/workflows/release.yml`: Linux x86_64 (Qt6), macOS arm64 (Cocoa, FPC 3.2.4rc1 as shipped with Lazarus 4.8 for macOS) and Windows x86_64 are built, packed by `opensloper-make.sh package` and started once from the download. The downloads become the GitHub release of `APP_VERSION` (tag `vVERSION`, a pre-release while 0.x), replaced on each push until the version changes. A development version (`0.10.0+dev`, between releases) is refused: the version is chosen at release time with `opensloper-make.sh bump` (see Releases and versioning in `coding-standards.md`); the notes are the version's `CHANGELOG.md` section, else the commits since the last release. Programs are stripped.

- **Linux:** a `.tar.gz` and a `.deb` (programs in `/usr/lib/opensloper`, linked from `/usr/bin`; menu entries, icons and file types under `/usr/share`). Both ship the Qt6 Pascal bindings in `lib/`, built from Lazarus's sources since Ubuntu packages them only from 26.04, found through an `$ORIGIN/lib` rpath. Needs Qt 6.4 and the glibc of Ubuntu 24.04 or later.
- **macOS:** a `.dmg` with one `OpenSloper.app` holding all the programs, opening on the design app, signed ad hoc. It declares the file types; Finder sends them to the design app, which starts the right app for each.
- **Windows:** a `.zip` and an Inno Setup `setup.exe` (`resources/windows/opensloper.iss`), for all users or the current user, with Start menu entries, the file types and an uninstaller.
- **OpenSSL for the assistant.** FPC 3.2.2 looks only for OpenSSL 1.1, so `Sloper.Assistant.Http` names OpenSSL 3 before its first connection (`LoadOpenSSL`). Linux uses the system's `libssl.so.3`; Windows and macOS ship OpenSSL 3 (`TAppPaths.LibraryDir`) and Mozilla's root certificates (`data/cacert.pem`, checked at packaging), since OpenSSL there cannot read the system's roots. `opensloper-cli check-connection` reports what loaded and is run from each download. Native HTTPS per platform was rejected: two more transports to test on machines CI cannot run.
- **User guide:** the site is built once for reading from disk (`opensloper-make.sh docs --offline`) and copied into each download's `data/help`.

Signing and notarisation wait for the community release (see [Open items](design/open-items.md)).

## Repository layout

All Pascal source is under `src/`, third-party code in submodules under `src/packages/`. `CLAUDE.md` lists every folder and script. The programs are built side by side into `release/` (not in git), so each app finds the others beside it and `data/` one folder up.

## Dependencies

Dependencies are kept to a minimum on purpose: each is code the project does not control, which can change, break, be withdrawn, change licence or carry a security problem. Seamly2D and Valentina also have few packages; the difference is that, apart from the packages below, everything OpenSloper needs comes with the compiler, with no separate framework such as Qt to install and no outside programs needed for output.

| Kind | What | Notes |
| --- | --- | --- |
| Compiler and libraries | Free Pascal, Lazarus (FCL, LCL, LazUtils) | GUI, JSON, XML, file handling, FPCUnit |
| Third-party packages | Clipper2 (Boost), BGRABitmap (modified LGPL) | Seam allowance and polygon booleans; antialiased drawing, SVG and PNG without the LCL |
| Our own package | ConsoleTools (MIT) | CLI argument parsing and help |
| Data | Tabler Icons (MIT), Noto Sans and DejaVu Sans | Files in `data/`, nothing linked |
| Platform | Qt bindings on Linux; OpenSSL 3 for the assistant | Loaded at run time |
| Optional | Blender 5.2 | Only for draping; found at run time |

Build-time tools (Zensical, JEDI Code Format, PasDoc) are not shipped and the apps build without them.

**Written ourselves instead**, where a library was larger than the job or would take control of the output: the formula parser (TFPExpressionParser's error positions and accepted syntax did not fit), the PDF writer (exact scale, the same layout gives the same bytes, so tests compare whole files), the DXF writer (R12 is simple and testable the same way), the JSON layout (fixed member order and number spelling) and the mesher (Clipper2's triangulation does not compile with FPC 3.2.2).

**Rules for adding a dependency.** All must hold:

1. **The problem is hard** (polygon clipping, font shaping, antialiased drawing); a small format or algorithm is written here instead.
2. **Its licence is GPLv3-compatible**, stated in a licence file in its repository.
3. **It is Pascal, or has no build step of its own**, so it compiles for every target, WebAssembly included. A C library is a last resort.
4. **The core stays LCL-free.**
5. **We could maintain it** if it is abandoned.
6. **It is pinned**: a submodule at a known commit, added and moved in commits of its own, with `opensloper-make.sh test` passing before and after.

A dependency used by one optional feature is kept out of the core and the other apps.

**Clipper2** comes from our fork ([github.com/opensloper/Clipper2](https://github.com/opensloper/Clipper2)) of AngusJohnson/Clipper2, with our fixes (see `documents/known-issues.md`). That repository was archived and development moved to PolyClipping/Clipper2, which is becoming C++ only, so the fork stays on the original; when we need to change it, it becomes our own Pascal-only Clipper2, keeping Angus Johnson's notices. Projects depend on `src/core/clipper2/osclipper2.lpk`. **ConsoleTools** ([github.com/billbsing/console-tools](https://github.com/billbsing/console-tools)) is ours; fixes go upstream.

## Testing

FPCUnit with the console runner, in `tests/`, run by `opensloper-make.sh test` with heaptrc, so leaks fail too. CI (`.github/workflows/ci.yml`) runs it with the formatter and the standards check. A pull request must also name the issue it is for in its title (`.github/workflows/pull-request.yml`, the Linked issue check). The LCL-free core means most logic is tested without a UI.

**What is covered:** geometry (with a tolerance helper, never exact float equality), formulas, evaluation order and states, IDs never reused, every operation against hand-checked cases and failures, piece detection and allowance, markings, transforms, seams, notes, materials, units and conversion, copy and paste, measurement files and merges, undo restoring the exact earlier state, save → load → save giving identical JSON, tiling, packing, PDF, SVG and DXF bytes, the mesher and the drape export, and the CLI commands through `RunCli`. Tables that document the program (operations, file members, API methods, CLI options, shortcuts, icons) are held to the code, and committed reference pages and schemas must match what the program writes.

**Regression patterns** in `tests/patterns/`: patterns with two measurement sets each and the expected `opensloper-cli check --json` report (each value, state and position to 1e-6 mm), so a change that silently alters a draft fails. `tests/patterns/README.md` says how to make one.

**Habits:** core tests alongside or before geometry and formula code; a failing test before every bug fix; the UI kept thin; end-to-end checks through `opensloper-cli serve` and its renders, and the GUI checked by hand on a private Xvfb display; `test` and `check` before every commit; `opensloper-make.sh pr-check` before a pull request.

## Documentation

**User documentation** is Markdown in `docs/`, built with Zensical (the successor to Material for MkDocs) from `zensical.toml` by `opensloper-make.sh docs` into `release/site_docs`, in strict mode so broken links fail. `.github/workflows/docs.yml` publishes it to GitHub Pages as two sites:

- **The root** (docs.opensloper.com) is the `release` branch's docs, named with its version. It is built again when `release.yml` publishes a release, so it matches the downloads.
- **`/dev/`** is the `development` branch's docs, named as development with its commit (`docs --dev`). It is built again on each push to `development` that touches the docs. `robots.txt` keeps it out of search engines.

A deployment replaces the whole site, so each run builds both.

Pages use only common extensions, so another generator would mean rewriting the navigation, not the pages. One site covers every app, since they share concepts, with pages written by task ("Add a size"), not by menu. CC BY-SA 4.0.

**Generated where it can be**, so the code is the single source of truth: `opensloper-cli doc TOPIC` (`src/docs/`) writes the reference pages from the tables the code uses (`functions`, `operations`, `files` and the schemas, `shortcuts`, `icons`, `cli`, `api`) and the Python client. They are committed, so the site builds without a Pascal toolchain, and a test fails while one differs from what the program writes. Tutorial and example patterns live in `docs/examples/` with their measurements; tutorial pictures are drawn by `export-draft --labels --upto=NAME` from `docs/tutorials/images.list`, and tests check every example opens without problems.

**Developer documentation** is made by PasDoc from the comments before each unit and declaration (`opensloper-make.sh devdocs` into `release/dev_docs`), with `documents/pasdoc-introduction.txt` as its first page. The comments stay in the plain `//` style of the coding standards, with no PasDoc tags. GitHub Pages publishes it from `development` at `/dev/pasdoc/`.

The guide's **Development** page (`docs/development.md`) says how to get the code, build it and run the tests, and links to the guide, its `/dev/` version, the PasDoc reference, the design and `CONTRIBUTING.md`. The README's Documentation section links the same.

`docs/` is the user documentation; `documents/` holds internal notes, including these design files.

## Translation

Not started; planned for the community release. Already in place: user text is in `resourcestring` sections (`opensloper-make.sh check` reports message text that is not), strings are UTF-8, and names in formulas and files are stable keys apart from what is shown.

- **Route:** gettext `.po` files, so translators use common tools (Poedit, Weblate). Templates go in `data/languages/`; the GUI apps use `LCLTranslator` (which also translates `.lfm` captions), the core and CLI LazUtils' `TranslateResourceStrings`. The language comes from a preference, then `--lang`, then the system.
- **The catalogue's** names, descriptions and how-tos get their own `.pot`, keyed by measurement.
- **Never translated:** formulas (keys, functions and the `.` decimal point, so a pattern means the same everywhere), saved files, API method and field names and error codes, and CLI output meant for scripts.
- **Exported text** (labels, information blocks) follows a language chosen in the output profile.
- **Rules for code now:** messages built with `Format` and placeholders, never by joining pieces; one resourcestring per sentence, plurals included; room for longer text (German runs about 30% longer); units, numbers and dates kept out of resourcestrings.

## Privacy

Measurement files hold body measurements, and file and folder names often name the client, so they are personal data. Everything stays on the user's machine except what an assistant reads: the Claude tabs send their questions and tool results to Anthropic's API, and an assistant connected to the design window sends what it reads to its own service. Nothing else is sent: no telemetry, no update checks.

The rule is that **no name is sent beside the measurements** (measurements without a name are not personal data under Singapore's PDPA, which this was checked against):

- **Files withheld.** The window's API servers (`WithholdsFiles` on `TApiServer`) name a pattern by its file name alone and the measurement file not at all, also inside error messages. `opensloper-cli serve` on its own gives full paths, since it opens only what its client names.
- **Measurements kept back, if the user chooses.** Preferences → General → **Let AI assistants read the measurements** (on by default) turned off refuses `get_measurements` and `set_measurement` and leaves them out of the Claude tab's tools. Computed points and renders still derive from the measurements, which the note in Preferences says.
- **Said before it is sent.** Each Claude tab's opening text says what goes to Anthropic, and the user guide has a Privacy section.

A pattern's own text (a note reading "Jane Smith's bodice") is sent as written; the user guide says to keep names out of patterns Claude will read.
