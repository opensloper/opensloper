---
description: "Get the OpenSloper source, build it with Lazarus and Free Pascal, run the tests and build the documentation."
icon: lucide/code
---

# Development

OpenSloper is open source, under the GNU GPL version 3 or later. The code is
on [GitHub](https://github.com/opensloper/opensloper). This page says how to
get it, build it and run the tests.

## The documentation

| Documentation | For |
| --- | --- |
| [User guide](https://docs.opensloper.com/) | The released version: this guide |
| [User guide, development](https://docs.opensloper.com/dev/) | What is not released yet, from the `development` branch |
| [Pascal source documentation](https://docs.opensloper.com/dev/pasdoc/) | Every unit and declaration, made by PasDoc from the comments in the code, from `development` |
| [Design](https://github.com/opensloper/opensloper/blob/development/documents/opensloper-design-document.md) | How the apps work and why, with the plans in its open items |
| [Contributing](https://github.com/opensloper/opensloper/blob/development/CONTRIBUTING.md) | How to send a change: checks, tests and what a good pull request looks like |

## What you need

- **Lazarus 4.8 with Free Pascal 3.2.2**, as CI uses, from your distribution
  or [lazarus-ide.org](https://www.lazarus-ide.org). Free Pascal 3.2.0 or later
  should work.
- **Git**.
- **On Linux**, the Qt Pascal bindings: `libQt6Pas` or `libQt5Pas`. Qt 6 is
  used when it is installed.
- **On macOS**, nothing more: the apps use Cocoa.

## Get the code

Clone with `--recursive`. The build needs the libraries in the submodules
(Clipper2, BGRABitmap and ConsoleTools).

```
git clone --recursive https://github.com/opensloper/opensloper.git
cd opensloper
```

If you cloned without `--recursive`, fetch them with:

```
git submodule update --init --recursive
```

Work is done on the `development` branch, which the clone starts on.

## Build and run

```
./opensloper-make.sh build
```

The apps are built into `release/`:

```
release/opensloper-design
release/opensloper-measurements
release/opensloper-publish
release/opensloper-drape
release/opensloper-cli
```

Run them from there. `./opensloper-make.sh build cli` builds only the
command-line program, for a quick check.

## Test and check

```
./opensloper-make.sh test      # build and run the tests, with leak checking
./opensloper-make.sh format    # format the sources
./opensloper-make.sh check     # the coding rules the formatter cannot check
./opensloper-make.sh pr-check  # all of these and the build, as CI runs them
```

Always build and test through `opensloper-make.sh`. It sets the compiler
flags and checks the results. `./opensloper-make.sh help` lists every command.

## Your own toolchain

To use a Lazarus or Free Pascal that is not on your `PATH`, such as an
fpcupdeluxe install:

1. Copy `build.local.sh.example` to `build.local.sh`.
2. Set the paths in it.

`build.local.sh` is not in git.

## The documentation, locally

| Command | Makes |
| --- | --- |
| `./opensloper-make.sh docs` | This guide, into `release/site_docs`. `--serve` previews it |
| `./opensloper-make.sh devdocs` | The Pascal source documentation, into `release/dev_docs`. Open `index.html` |

`docs` writes the reference pages with the built `opensloper-cli`, so build first.
It makes a Python virtual environment in `venv/` with Zensical the first time.
The source documentation needs [PasDoc](https://pasdoc.github.io/); set
`PASDOC` if it is not on your `PATH`.

## The web version

The web apps run the same Pascal engine, compiled to WebAssembly, under a
TypeScript editor. They need Free Pascal trunk and Node.js.
`web/README.md` in the repository says how to build and test them.
