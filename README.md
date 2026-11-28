# OpenSloper

OpenSloper is a parametric sewing pattern drafting application written in Lazarus/Free Pascal. A pattern is drawn from formulas based on body measurements, so it redraws itself when the measurements or the size change. It owes much to Valentina and Seamly2D, the open source parametric pattern programs whose ideas it builds on.

## Status

OpenSloper is in active development and released regularly. The current release is on the [releases page](https://github.com/opensloper/opensloper/releases/latest).

- Desktop apps for Linux, Windows and macOS: Design, Measurements, Publish (layouts and printing) and Drape (pieces placed round a body for draping in Blender).
- `opensloper-cli` for export, layout and checks from the command line.
- Export to PDF, SVG, DXF and PNG; import and export of Valentina and Seamly2D measurement files.
- An automation API (JSON-RPC 2.0) with an MCP server and a Python client.
- A web version, in beta, at [opensloper.com](https://opensloper.com/): the same Pascal engine compiled to WebAssembly.

File formats may still change between releases. The design is in `documents/opensloper-design-document.md`, what is not built yet in `documents/design/open-items.md`, and open problems in `documents/known-issues.md`.

## Development

To clone this project, you must use `--recursive`, since this project contains submodules that are used in the build process.

Build with the release toolchain that CI uses: Lazarus 4.8 with FPC 3.2.2 (from your distribution, or the packages at [lazarus-ide.org](https://www.lazarus-ide.org)).

```
git clone --recursive https://github.com/opensloper/opensloper.git
cd opensloper
./opensloper-make.sh build
```

## Building

Requires Lazarus with FPC 3.2.0 or later. Linux uses the Qt5/Qt6 widgetset (`libQt5Pas`, `libQt6Pas`); `opensloper-make.sh build` picks Qt6 when `libQt6Pas` is installed, else Qt5 (set `LCL_WIDGETSET` to choose). macOS uses Cocoa.

```
git submodule update --init --recursive
./opensloper-make.sh test   # build and run the tests (with leak checking)
./opensloper-make.sh build  # build the four GUI apps and the CLI into release/
```

To contribute, see `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`. To report a security problem, see `SECURITY.md`.

To use a Lazarus/FPC that is not on `PATH` (for example an fpcupdeluxe install), copy `build.local.sh.example` to `build.local.sh` and edit the paths.

## Documentation

- [User guide](https://docs.opensloper.com/), for the released version; [development version](https://docs.opensloper.com/dev/), from `development`. Its source is in `docs/`.
- [Development](https://docs.opensloper.com/dev/development/): getting the code, building, testing and the documentation (`docs/development.md`).
- [Pascal source documentation](https://docs.opensloper.com/dev/pasdoc/), made by PasDoc from `development`. Build it locally with `./opensloper-make.sh devdocs` into `release/dev_docs`.
- Design: `documents/opensloper-design-document.md`.

## Licence

GPLv3 or later; see `LICENSE`.


