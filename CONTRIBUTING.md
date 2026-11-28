# Contributing to OpenSloper

Thank you for helping. This page covers what a pull request needs before it can be merged. Read `CLAUDE.md` for the project's layout and rules, and `documents/coding-standards.md` for how the code is written.

Everyone taking part in the project is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md). Report security problems privately, as described in [SECURITY.md](SECURITY.md), not in a public issue.

## Toolchain

Use the release toolchain that CI uses: **Lazarus 4.8 with FPC 3.2.2**. The formatter is built from your Lazarus's own source, so a different Lazarus version may format code differently and fail the CI formatting check. On Linux, the GUI apps also need the Qt5 or Qt6 Pascal bindings (`libQt5Pas` or `libQt6Pas`).

```
git clone --recursive https://github.com/opensloper/opensloper.git
cd opensloper
./opensloper-make.sh test
./opensloper-make.sh build
```

## Before you open a pull request

Every pull request is for an issue. Open one first, or find the one it is
for, and end the pull request's title with its number, such as
`Fix the hem allowance (#123)`. The **Linked issue** check fails until the
title names an issue of this repository; it runs again when you edit the
title.

Run this and fix anything it reports:

```
./opensloper-make.sh pr-check
```

It runs these four in turn and stops at the first that fails:

```
./opensloper-make.sh format  # format the sources (./opensloper-make.sh format --check lists files only)
./opensloper-make.sh check   # rules the formatter cannot check
./opensloper-make.sh test    # tests, with the heaptrc leak check
./opensloper-make.sh build   # the GUI apps and the CLI
./opensloper-make.sh build cli design  # only the apps named, while you work
```

Formatting changes files in place, so when all four pass, `pr-check` lists the files it reformatted: commit them with your change.

CI runs the same checks on every pull request, with the Linked issue check, and they must pass before a merge. `opensloper-make.sh check` also prints warnings, such as single-letter names. Warnings don't fail the check, but please fix them in code you add.

## What a good pull request looks like

- **The issue in the title.** End the title with the number of the issue it is for, such as `Fix the hem allowance (#123)`. The Linked issue check fails without it.
- **One change per pull request.** Keep refactoring separate from features and fixes.
- **Tests.** New geometry and formula code comes with core tests. A bug fix starts with a test that fails without the fix. Compare coordinates with a tolerance, never with exact equality.
- **No leaks.** heaptrc must report 0 unfreed blocks.
- **Layers.** `src/core/` has no LCL dependency. The API works through document commands. The UI stays thin. Every user change is an undoable `TCommand`.
- **Text.** User-visible text goes in `resourcestring` sections.
- **Design.** If the change alters a design decision, update the design (`documents/opensloper-design-document.md` or the file for that part in `documents/design/`) in the same pull request. Open an issue to discuss larger changes before writing the code.
- **Third-party code.** Don't edit `src/packages/`. Send changes to Clipper2, BGRABitmap or ConsoleTools to their own projects.
- **Changelog.** Add a line for anything a user would notice to `CHANGELOG.md`, under `## Unreleased`, with the issue number if there is one. A release with no notes there lists its commits instead, so a fix also says `Closes #N` in its commit message.
- **Commits.** Write commit messages that say what the change does and why.

## Pascal source documentation

GitHub Pages publishes the [Pascal source documentation](https://docs.opensloper.com/dev/pasdoc/)
from `development`. Build it locally with `./opensloper-make.sh devdocs`
and open `release/dev_docs/index.html`. Set `PASDOC` if the binary is outside
your `PATH`.

## Licence

OpenSloper is licensed under the GNU GPL, version 3 or later. By submitting a pull request, you agree that your contribution is licensed under the same terms. Every new source file starts with the header in `documents/gpl-header.txt`. Code translated from Valentina or Seamly2D keeps their copyright line.
