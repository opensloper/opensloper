---
description: "Download and install OpenSloper on Linux, macOS or Windows, or build it from source, and draft your first sewing pattern."
---

# Getting started

OpenSloper runs on Linux, macOS and Windows. Download it from the
[releases page](https://github.com/opensloper/opensloper/releases), or build
it from source.

## Install

| Download | For |
| --- | --- |
| `opensloper_VERSION_amd64.deb` | Debian 13 and Ubuntu 24.04 or later: open it, or run `sudo apt install ./opensloper_VERSION_amd64.deb` |
| `opensloper-VERSION-linux-x86_64.tar.gz` | Other Linux distributions: unpack it and run the programs from its folder; its `README.txt` says how to add them to the menu |
| `opensloper-VERSION-macos-arm64.dmg` | macOS 11 or later on Apple silicon: drag OpenSloper to Applications |
| `opensloper-VERSION-windows-x86_64-setup.exe` | Windows 10 or later: run it to install |
| `opensloper-VERSION-windows-x86_64.zip` | Windows, to run from a folder without installing |

The installers add OpenSloper to the menu, and open patterns (`.sloper`),
measurement files (`.slm`) and layouts (`.slayout`) in their apps when you
double-click them. This guide comes with every download: choose
Help → User Guide in any of the apps.

### Portable

To run OpenSloper from a USB stick or a folder of its own, leaving nothing on
the computer, unpack the `.zip` (Windows) or `.tar.gz` (Linux) and put an
empty file named `portable.ini` beside the programs. On macOS, put it beside
`OpenSloper.app`. The apps then keep everything they write beside it: your
settings, recent files and cache in a `user` folder, and patterns in
`documents` unless you save them elsewhere. Recent files kept on the stick
are found again when it gets another drive letter. Your Claude API key, if you
enter one, is kept in `user` too, so keep the stick safe.

The programs are not signed yet. If macOS says OpenSloper cannot be opened or
is damaged, run `xattr -cr /Applications/OpenSloper.app` once in Terminal. On
Windows, if SmartScreen asks, choose More info, then Run anyway.

## Build from source

### What you need

- **Lazarus 4.8 with Free Pascal 3.2.2**, from your distribution or
  [lazarus-ide.org](https://www.lazarus-ide.org). Other versions from Free
  Pascal 3.2.0 on should work.
- **Git**, to fetch the code and the libraries it uses.
- **On Linux**, the Qt Pascal bindings: `libQt6Pas` or `libQt5Pas`. Qt 6 is
  used when it is installed.

### Build

```
git clone --recursive https://github.com/opensloper/opensloper.git
cd opensloper
./opensloper-make.sh build
```

The apps are built into `release/`:

```
release/opensloper-design
release/opensloper-measurements
release/opensloper-publish
release/opensloper-cli
```

If you cloned without `--recursive`, fetch the libraries first with
`git submodule update --init --recursive`.

## First steps

1. Start **opensloper-measurements** and make a measurement file (`.slm`) with
   the measurements your pattern needs, or open one you have.
2. Start **opensloper-design**, make a new pattern (File → New) and choose its
   measurement file (File → Measurements → Open Set…). Draw points and lines; their places are formulas that can read
   the measurements.
3. Make pieces from the closed outlines, then open **opensloper-publish** from
   the design app (File → Publish…) to lay the pieces out and print them.

## Preferences

Edit → Preferences… sets the unit you work in (mm, cm or inches), the grid
spacing and the printer calibration. The apps share them. A new pattern
takes the unit from Preferences; a pattern keeps the unit it was made in, and
Tools → Convert Pattern Units… changes it.

Settings are kept in `~/.config/opensloper/` on Linux, `%APPDATA%\OpenSloper`
on Windows and `~/Library/Application Support/OpenSloper` on macOS, or in the
`user` folder of a [portable](#portable) copy.
