---
description: "Put sewing instructions, sizes and worked-out values on a pattern with notes, callouts pointing at details, and drawn stamps."
---

# Notes, callouts and stamps

Notes put text on the pattern: sewing instructions such as *Stay-stitch the
neckline*, the size a piece was drafted for, or a value worked out from the
measurements. A callout is a note with a line to what it is about, pointing at
a notch, a dart or a seam. A stamp is a note that shows a drawing from
another app, such as a logo or a folding diagram, in place of text (see
[Stamps](#stamps)).

## Add a note

Choose the Text tool (++x++) and click. The note hangs from what the click
snaps to, a point, a place on an edge, or a piece, and moves with it when the
pattern changes. Clicked on nothing, it is a free note that stays where it is
put. Its text is selected in the properties, ready to type over, and the side
panel opens if it was hidden. To change a note's text later, double-click it.

The note on the canvas follows the text as you type, with values worked out
once their formula does; leaving the text box keeps the change as one undo
step, and ++escape++ puts the text back.

Choose the Callout tool (++a++), click what it points at, then click where its
text goes. The text hangs from the place it points at. ++escape++ stops either
tool.

A note's place is kept as a distance across and down from what it hangs from,
in the **Across** and **Down** rows. Drag the note to change them while they are
plain numbers; once either is a formula, change it in the properties. Dragging a callout's tip onto something else hangs it
from that instead.

## Properties

| Row | Meaning |
| --- | --- |
| Text | The text, on several lines if you like |
| Size (points) | The text size when printed at true size; 10 unless you change it |
| Print | Whether it prints and exports with its piece. Turn it off for notes to yourself |
| Hangs from | The point, edge or piece it moves with, or Nothing (free) |
| Make free | Unhooks the note and leaves it where it is |
| Leader | None for a plain note; Arrow, Dot or Line for a callout |
| Lines | Left, Centred or Right |
| Box | On a white box, so it reads over lines and fills |
| Font | The font it prints in: one from the list or a name typed in; the default is a plain sans-serif |
| Style | Bold, italic, or both |
| Scale | A stamp only: how much bigger than its true size it is drawn; 1 unless you change it |

A point, edge or piece cannot be deleted while a note hangs from it: make the
note free first, or delete it.

## Fonts

A note is drawn and printed in its own font, so a print matches the screen.
PDF files carry the font with them, cut down to the letters used, so they
print the same on any computer. When the font has no bold or italic form, the
PDF draws one from its regular form.

A font that is not installed, that has PostScript (CFF) outlines rather than
TrueType ones, or whose licence does not allow it to be embedded prints in the
default font instead, and the publish app lists a warning. Most `.ttf` fonts
embed; some `.otf` fonts do not.

The default font prints as Helvetica, which every PDF reader has. Text that
Helvetica cannot print, such as Greek or Cyrillic, prints in Noto Sans, which
comes with OpenSloper.

## Values from the draft

Text in `{= }` is a formula, worked out again whenever the pattern changes, in
the pattern's unit:

```
Waist {=Waist.length * 4} cm
Dart {=#dart} cm, ease {=@hip / 20}
```

Each value has its own row, **Value 1**, **Value 2** and so on, showing what it
works out to. A formula that fails blocks the note until it is fixed, and
renaming what it reads changes the text to match.

A few names in braces are filled in when the pattern is printed:
`{pattern.name}`, `{measurements.name}`, `{size}` (the size chosen from a
size table), `{date}`, `{cutlist}` and `{materials}`.

A note that prints with a piece (see below) can also name the piece, which
makes a label of your own:

```
{piece.name}
{piece.cut}, {piece.material}
Size {size}
```

prints as "Front", "cut 2 on fold, Main" and "Size 38". Each copy in a layout
fills in its own piece, and a piece opened out at the fold prints its cut
without "on fold". A note that prints with no piece, or with more than one,
keeps the piece fields as typed. To print only your own label, leave labels
out in the publish app's output profile.

## Stamps

File → Import SVG Stamp... puts an SVG drawing on the pattern, made in
Inkscape, Illustrator or any app that saves SVG. In the web Design app, use
**Import SVG Stamp…** on the toolbar. The file is read on your device.
With one point, edge or piece selected, the stamp hangs from it, centred
on the point, the middle of the edge or the middle of the piece; otherwise
it is free, in the middle of the view. It moves with what it hangs from like any note, can have a leader, and
prints with its piece.

The drawing is drawn at its true size, from the size the SVG file gives:
a drawing 40 mm wide prints 40 mm wide. A file whose size is in pixels, or
that gives no size, is taken at 96 pixels to the inch, with a warning. The
**Scale** row makes it bigger or smaller.

The drawing is copied into the pattern, so the pattern does not need the SVG
file again. To change the drawing, import it again and delete the old stamp.

A stamp keeps the drawing's fill and stroke colours. Only shapes are read:

- **Text** is refused, so the pattern does not depend on fonts. Convert text
  to paths first: in Inkscape, select it and choose Path → Object to Path.
- **Bitmap images** are refused; a stamp can only hold shapes.
- **Clones** (`<use>`) are refused: in Inkscape, Edit → Clone → Unlink Clone.
- Gradients are drawn in black, and transparency, clipping, masks and style
  sheets are left out, with a warning saying so.

A stamp's text is not drawn: it only names the stamp in the object list, and
starts as the file's name. A stamp has no size, font or alignment rows.

## Showing and printing

View → Annotations shows or hides every note on the canvas; the pattern
remembers the choice, and it is not an undo step.

A note prints with a piece when it hangs from the piece, or from one of its
points or edges, or when its text starts inside the piece's cutting line. It
follows the piece in the layout and stays upright when the piece is flipped.
Other notes are left out of layouts, and a printing note on no piece is listed
as a warning. Notes and stamps are not written to DXF files.
