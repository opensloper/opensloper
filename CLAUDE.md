# OpenSloper

Parametric sewing pattern drafting application in Lazarus / Free Pascal. GPLv3 or later.

The design is in `documents/opensloper-design-document.md`, the overview and index, with a file per app and the Automation API in `documents/design/`. Read the parts you touch before making architectural changes, and keep them up to date when a design decision changes; what is not built yet goes in `documents/design/open-items.md`.

## Layout

- `src/core/` — geometry, expressions, model, evaluator, piece builder, storage. **No LCL dependency**: never add `Forms`, `Graphics`, `Controls` or other LCL units here.
- `src/document/` — `TPatternDocument`, undo/redo commands, change notifications.
- `src/editor/` — editing logic the desktop and web editors share, **without the LCL**: the canvas scene and snapping, the view transform and ruler ticks, formula completion and suggestions, the object lists and the edits to a selection or a panel's rows. Uses only core and document. Logic in `src/ui` that needs no LCL belongs here, so the web engine can offer it through the API.
- `src/ui/` — forms, canvas, interaction tools, panels. Keep it thin: call into editor, document and core.
- `src/output/` — PDF, SVG, DXF and Blender exporters; read computed geometry only. `src/output/thirdparty/` holds our own units that draw with BGRABitmap built without the LCL (the draft as PNG); every standard applies there, and only those BGRA units are allowed besides.
- `src/api/` — the Automation API (JSON-RPC 2.0), its MCP server, the design window's automation socket (endpoint, listener, and the connection `serve --connect` uses), and the apps' link (`Sloper.API.AppLink`), on which every app's window listens, so Publish… finds the publish window already open and a change of preferences reaches the apps already open. Depends only on the document, editor, core and output; every edit goes through document commands.
- `src/assistant/` — the in-app Claude assistant, without the LCL: the API key file, the streamed response, the HTTPS transport and the conversation's tool loop. Its panel is `Sloper.UI.AssistantPanel`.
- `src/design/` — `opensloper-design`, the main design app, with its main form (`Sloper.Design.MainForm`), as the measurements and publish apps keep theirs.
- `src/measurements/` — `opensloper-measurements`, which edits measurement files and size tables. Keep it thin, as `src/ui`.
- `src/publish/` — `opensloper-publish`, layouts and printing.
- `src/drape/` — `opensloper-drape`, which places pattern pieces round a body in 3D for draping in Blender (issue #11). Keep it thin, as `src/ui`: the placement maths, body, scene, mesher and drape file are core units (`Sloper.Core.Drape*`, `Sloper.Core.BodyForm`, `Sloper.Core.Mesher`), and its undo document is `Sloper.Document.DrapeDocument`.
- `src/cli/` — `opensloper-cli` (export, export-draft, layout, pack, drape, materials, check, measurements, serve, check-connection, doc), built on the core and ConsoleTools; check-connection uses the assistant's HTTPS transport. Its commands and options are tables in `Sloper.CLI.Arguments`, which build the parser and the CLI reference page. The commands run in `Sloper.CLI.Commands` (`RunCli`), writing to the text files given, so `Sloper.Tests.CLI` runs them in the test program; a new command gets a test there.
- `src/docs/` — code that writes the generated reference pages, the file format schemas and the Python API client (`opensloper.py`) of the user documentation (`opensloper-cli doc TOPIC`). Doc generation code goes here.
- `web/engine/` — the web engine spike: `src/core`, `src/document`, `src/api` and `src/output` compiled for `wasm32-wasip1` with FPC trunk (its README says how to build the compiler); `stubs/` holds stand-ins, under the real units' names, for units the Wasm build leaves out (PNG drawing). `compare.py` checks it against the desktop on the regression patterns. `browser/` is the spike's timing page.
- `web/` — the web version (issue #78, `web/README.md`): one npm project for its TypeScript, checked by `tsc`, Oxlint and Prettier (see the TypeScript section of `coding-standards.md`), which `opensloper-make.sh check` and `format` run when npm is found, and built by `opensloper-make.sh web` into `web/out/design`. `web/src/` mirrors the Pascal folders: `engine/` (the worker and `Engine`), `document/` (`PatternDocument`, a proxy of the engine's), `editor/` (copies of per-frame `src/editor` logic, such as `view.ts`, kept the same as the Pascal), `ui/` (modules named after their `src/ui` units) and `design/` (the app's page). Editing logic stays in Pascal behind the editor methods (`Sloper.API.EditorServer`); the TypeScript draws and handles input.
- `site/` — opensloper.com (issue #86, `site/README.md`): a Django site with no database, the home page in `pages/` and, at `/design/`, the web Design app, a beta. `manage.py import_opensloper` copies the built app (`web/out/design`), the logo, icons, tutorial drawings and version from this checkout into `site/imported/` (not in git); `deploy/` holds the gunicorn service and the Apache directives. Licensed GPLv3 like the rest; secrets stay in the server's environment file, never in git.
- `src/packages/` — git submodules (Clipper2, BGRABitmap, ConsoleTools). Do not edit code in here; changes go upstream.
- `resources/` — branding: app icons and the API logo (SVG), for builds, docs and other resources; `make-icons.sh` regenerates the apps' `.ico` files and the web app's PNGs (`web/`) after an SVG changes, `linux/` holds the `.desktop` entries and the file types (`opensloper.xml`), `windows/` the Inno Setup installer script, and `licenses/` the licence texts of what the downloads bundle (OpenSSL's Apache 2.0).
- `data/` — files the apps read at run time: the Blender script a drape export copies (`data/blender/drape.py`), the measurement catalogue and its body figures, the Tabler toolbar icons (`data/icons`, MIT), and the fonts images are drawn with (`data/fonts`: Noto Sans, OFL, and DejaVu Sans, Bitstream Vera licence).
- `tests/` — FPCUnit test project and regression patterns.
- `src/core/clipper2/osclipper2.lpk` — Lazarus package that builds Clipper2 from the submodule; projects depend on it rather than adding Clipper2 to their search path.
- `documents/` — internal development notes, the design (`opensloper-design-document.md` and `design/`), `coding-standards.md`, `known-issues.md` and the GPL unit header (`gpl-header.txt`).
- `docs/` — user documentation (Markdown, built with Zensical from `zensical.toml`, licensed CC BY-SA 4.0). `docs/examples/` holds the tutorial and example patterns with their measurements, which readers download from the site and a test opens. `docs/reference/` holds generated pages and the generated Python client `opensloper.py`, and `docs/reference/schemas/` the generated JSON Schemas of the user files: never edit them by hand; run `./opensloper-make.sh build` then `./opensloper-make.sh docs`, and a test fails while a committed page is out of date.

## Build and test

```
git submodule update --init --recursive
./opensloper-make.sh help     # the commands and their options
./opensloper-make.sh test     # tests, with heaptrc leak check
./opensloper-make.sh test --suite=TTestFacing  # one suite (runner options pass through)
./opensloper-make.sh build    # GUI apps and CLI, into release/ (not in git)
./opensloper-make.sh build cli tests  # only those (cli, design, publish, measurements, drape, tests), for a quick check
./opensloper-make.sh web      # the web engine for Wasm into web/engine/out, with FPC trunk (web/engine/README.md); --strip-names drops the function names
./opensloper-make.sh site     # import the built web app into the Django site (site/), check and test it; --serve runs it locally
./opensloper-make.sh package  # pack the built apps and installer for this platform into release/dist, with the offline guide from docs --offline (the release workflow runs it)
./opensloper-make.sh release  # a release's notes: APP_VERSION's CHANGELOG.md section (Unreleased while VERSION+dev), else its commits since the last release
./opensloper-make.sh bump minor  # the release's version (major|minor|patch|X.Y.Z): sets APP_VERSION, names CHANGELOG.md's Unreleased section; bump dev after a release sets VERSION+dev; commits nothing (see Releases in coding-standards.md)
./opensloper-make.sh format   # format sources with jcfsettings.cfg (--check to list only)
./opensloper-make.sh check    # rules the formatter cannot check (errors fail, warnings advise)
./opensloper-make.sh pr-check # format, check, test and build in turn, stopping at the first failure; lists files format changed
./opensloper-make.sh docs     # regenerate docs/reference/ and build the site into release/site_docs (--serve to preview)
./opensloper-make.sh devdocs  # developer documentation of the code with PasDoc into release/dev_docs (not published or packaged)
./venv/bin/python check-schemas.py  # check example and regression files against the file schemas (opensloper-make.sh docs runs it)
```

Always build, test, format, check and make docs through `./opensloper-make.sh`, even for a quick check: never call `lazbuild`, the compiler or `tests/opensloper_tests` directly, as the script sets the flags (`-B`, heaptrc, the widgetset) and checks the results.

Toolchain overrides (`LAZBUILD`, `LAZARUS_PCP`, `LCL_WIDGETSET`, `JCF_SOURCE`, `PASDOC`) go in the gitignored `build.local.sh`; see `build.local.sh.example`.

Requires FPC 3.2.0 or later; CI (`.github/workflows/ci.yml`) uses the release Lazarus 4.8 with FPC 3.2.2, and its formatter is the reference. Linux uses the Qt5/Qt6 widgetset; macOS uses Cocoa. Run `opensloper-make.sh test` and `opensloper-make.sh check` before every commit. Pull request rules are in `CONTRIBUTING.md`.

## Conventions

- Every source unit starts with the GPLv3 header. Code translated from Valentina or Seamly2D keeps their copyright line.
- Internal units are millimetres: geometry, computed state and exports. Formula numbers are in the pattern's unit (mm, cm or in), converted where they become geometry (see Pattern units in the design). Coordinates are x right, y down, as on screen and in Seamly2D. Angles are degrees, 0° pointing right, positive anticlockwise as seen on screen, so 90° points up.
- Only definitions (operations, references, formula strings) are saved and undone; computed geometry is always derived.
- Objects are referenced by stable integer IDs (`12`, `7`), never reused; names are for display only. Formulas are stored in ID form and shown with names.
- Names: letters, digits and underscore, not starting with a digit; unique per namespace; compared case-insensitively. Copies get the next free number appended directly (`A` → `A2`).
- Every user change is a `TCommand` with `Execute` and `Undo`; one drag is one undo step.
- Evaluation failures are states (error, invalid, blocked), never exceptions that escape to the UI.
- User-visible text goes in `resourcestring` sections.
- Code style (naming, formatting, line length) follows `documents/coding-standards.md`; read it before writing code. Run `./opensloper-make.sh format` before committing.
- File paths go through `TAppPaths`; build paths with `ConcatPaths` / `PathDelim`, never a hard-coded `/`.
- Every program lists `Sloper.Core.CodePage` first in its uses clause and is compiled with `-FcUTF8`, so strings are UTF-8 throughout.
- Files are written through `Sloper.Core.JSON` (`JSONToText`, `JSONFloat`) for a stable layout; loading reports errors as messages, never exceptions.
- Shortcuts use `ssModifier`, not a hard-coded Ctrl. A key macOS keeps for itself with Cmd (Cmd+Tab) is written `Ctrl` in `Sloper.Core.Shortcuts` and becomes the Control key on every platform, through `CONTROL_KEY` in `Sloper.UI.Commands`, the one `ssCtrl` the check allows.

## Testing

- Write core tests alongside or before geometry and formula code.
- Every bug gets a failing test before the fix.
- Compare coordinates with a tolerance helper, never exact float equality.
- Tests are built with heaptrc (`-gh`); fix any reported leaks.
