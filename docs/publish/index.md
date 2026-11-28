---
description: "Lay out pattern pieces and print them at true size: tiled on home printer pages, on a large sheet, by projector or for a cutting machine."
---

# The publish window

**opensloper-publish** lays out the pieces of finished patterns and prints
them at true size: on home printer pages taped together, on one large sheet,
through a projector onto the material, or as files for a cutting machine. A
layout is saved as a `.slayout` file.

## Start a layout

In the design app, File → Publish… (++ctrl+p++) opens the publish app with the
pattern's layout, the file of the same name ending `.slayout`, or starts a new
one with every piece placed. It reads the saved pattern, so an unsaved pattern
is saved first, and a changed one asks whether to save. If a publish window
already shows that layout, Publish… brings it to the front instead of opening
another.

You can also open the publish app on its own: File → Open… takes a layout, or
a pattern to start a layout for.

## Parts of the window

- **The pages**, on the left: the pieces where they lie, over the sheets they
  print on. Each page's printable area is white, and grey when nothing prints
  on it. The status bar counts the pages.
- **Tabs**, on the right, one open at a time, as in the design app's side
  panel: click a tab's icon, down the panel's left, to open it, or the open
  tab's icon to fold the panel down to its icons. [Icons](../reference/icons.md#side-panel-tabs_1)
  shows each tab's icon:

    | Tab | What it holds |
    | --- | --- |
    | Patterns | The patterns in the layout, each with its measurements and size |
    | Pieces | The selected piece (Turn 90°, Flip, Back to tray), Place new pieces, Pack pieces, and the tray of pieces not yet placed |
    | Materials | How much of each material the patterns need, and notes on it (see [Material needed](printing.md#material-needed)) |
    | Information Block | The pattern, measurements, date and other details, printed in a page corner |
    | Notes | Text placed on the pages |
    | Output | What it prints on, the paper, marks, fill and profiles, and the exports |
    | Claude | Ask Claude to arrange the layout (see [Asking Claude](arrange.md#asking-claude)) |
    | Problems | Everything that stops the layout printing, in red, and the warnings; click one to select its piece or note |

- **Problems**, counted at the left of the status bar at the bottom: anything
  that stops the layout printing, such as a missing pattern, and warnings,
  such as overlapping pieces. Click the count to open the Problems tab.

The wheel zooms about the pointer, and View → Zoom In and Zoom Out
(++ctrl+plus++ and ++ctrl+minus++) zoom about the middle; drag with the middle
button, hold ++space++ and drag, or use the scroll bars, to pan. View → Fit Pages (++ctrl+0++)
shows every page. View → Zoom Area (++z++) zooms to a box dragged over the
pages; while it is on, a click zooms in, ++shift++ and click zooms out, and
pieces stay put. Press ++z++ again, or ++escape++, to move pieces again.

## Patterns and sizes

A layout can hold several patterns, and the same pattern more than once, in
different sizes. On the Patterns tab, **Add pattern…** and **Remove pattern**
change the list. For the pattern selected there, **Choose measurements…** picks
the measurement file to draw it with, **Use the pattern's own** goes back to
the file the pattern names, and **Size** chooses the size of a size table.

The layout follows its patterns. When a pattern or measurement file is saved,
the layout reads it again within a second or two, and new pieces wait in the
tray. View → Reload Patterns (++ctrl+r++) reads everything again by hand.

Every change to a layout is a step in Edit → Undo (++ctrl+z++).

## In the browser

The publish app also runs in the browser, as a beta, at
[opensloper.com/publish/](https://www.opensloper.com/publish/), with nothing
to install. It uses the same engine as the desktop app, so layouts open in
both.

- **Open** takes a layout together with its patterns and measurement files,
  or patterns alone to start a layout. The app asks for any file the layout
  still needs.
- The keys are the desktop's.
- The tabs are the desktop's, but there is no Claude tab.
- **Print…** opens the PDF in the browser's viewer, or downloads it. Print
  the cover first and check its test square.
- Export writes PDF, SVG and DXF-AAMA. Machine DXF is on the desktop only.
- In Chrome and Edge, Save writes back to the layout's file, and Open can
  find the layout's patterns in a folder you choose. Other browsers save as
  a download.
- Your files stay on your computer. Work you have not saved is kept in the
  browser and offered back next time.
- Once it has loaded, the app can be installed and works offline.
