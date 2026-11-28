---
description: "Arrange pattern pieces on the material, with each piece placed as many times as it is cut and mirrored copies flipped."
---

# Arrange pieces

Each piece is placed as many times as its pattern says to cut it. A piece cut
twice and mirrored gets its second copy flipped.

## Move, turn and flip

Click a piece to select it and drag it where you want it; it moves in 0.5 mm
steps. ++escape++ during a drag puts it back.

On the Pieces tab:

- **Turn 90°** turns the selected piece a quarter turn. Pieces only turn in
  quarter turns, so the grainline stays square to the sheet; the printed
  grainline shows how to lay it on the material.
- **Flip** turns it over, for a mirrored copy.
- **Back to tray** takes it off the pages. ++delete++ does the same.

## The tray

The tray lists copies with no place yet: new pieces, and copies taken back.
Drag one onto the pages to place it under the pointer, or double-click it to
put it in a new row. **Place new pieces** places them all in rows.

A piece with a problem in its pattern waits in the tray until the pattern is
fixed.

## Pack pieces

**Pack pieces** arranges every copy, including those in the tray, to use as
few pages, or as short a sheet, as it can. It follows the pieces' shapes, so
a small piece can go in the curve or notch of a larger one: each goes as high
on the sheet, then as far left, as its cutting line fits. It tries each piece as
it stands and a quarter turn from it, keeps pieces at least 10 mm apart, and
keeps flips. Packed pieces lie on the half-millimetre drag grid. When your own
arrangement already does better, it is kept, and the status bar says so.

Packing is one step to undo, and the pieces can still be dragged afterwards.

## Warnings

The Problems tab, at the foot of the side panel, warns about pieces that overlap, pieces off the sheet,
copies still in the tray and, where a piece is cut as it lies, a piece turned
across the grain. Warnings do not stop printing; problems such as a missing
pattern do, so a blank page is never printed, and are listed in red. Click a
problem to select the piece or note it is about. The status bar counts them;
click the count to open the tab.

## Asking Claude

The **Claude** tab lets you ask Claude to arrange the layout, or why something
is wrong, in your own words: "pack the pieces on 150 cm material", "why does
the front overlap the facing?". It uses the Anthropic API key set in the
General tab of **Edit → Preferences**, the same key as the design app's Claude
tab (see [Asking Claude](../design/claude.md#setting-it-up)).

Claude places, turns, flips and packs pieces, changes what the layout prints
on, and adds notes and the information block, as you can on the tabs, and can
look at the sheet as a picture. Each change is one step on the undo history.
It cannot save, export or print.

Sent to Anthropic: your questions, the layout's settings and notes, its
pieces' names, places and sizes, and pictures of the sheet. Patterns are
named by their file names; folders, the measurement files' names and their
values are never sent, though the pieces' sizes are worked out from them.
