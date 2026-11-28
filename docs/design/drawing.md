---
description: "Draw points and lines freely while OpenSloper records how each was placed, so the pattern follows the measurements when they change."
---

# Draw points and lines

You draw freely, and OpenSloper records *how* each point was placed: what it
was measured from and how far. When the measurements change, the point moves
with them.

## Snapping decides the operation

With the Point, Line or Curve tool, the pointer snaps to what is near it, and
that decides what kind of point a click makes. In order:

| Near | A click makes | Operation |
| --- | --- | --- |
| An existing point | Uses that point | — |
| Where two edges cross | A point at the crossing | Intersection of edges |
| An edge | A point on it, measured from its nearer end | Point along an edge |
| Level with a point, or straight above or below it | A point that distance from it | Offset point |
| Nothing, while drawing a line or curve | A point across and down from where it starts | Offset point |
| Nothing | A point where you click | Free point |

A marker shows the kind of snap, a dotted guide shows the point it lines up
with, and the status bar says what the click will make, such as *New point
30 mm right of B*. While drawing a line, its start point is lined up with first.

Distances are rounded to a tenth of a millimetre (or 0.1 cm, 0.01 in in those
units), ready to be replaced by a formula in the Properties tab. When a snap
made the wrong kind of point, [change its type](points.md#changing-a-points-type)
instead of drawing it again.

## Lines and curves

Lines and curves take two clicks, and drawing carries on from the end. So
you can draft a whole outline with the Line or Curve tool alone:

- The first click in open space makes a free point.
- Each later click in open space makes a point across and down from the
  point before, such as *New point 120 across and 80 down from B*.
- Moving the first point moves the whole outline, and an across or down
  length can become a formula, such as `@waist / 4`.
- Click the first point again to close the outline.

With
the Curve tool, hold ++shift++ as you click to carry the last curve on through
the point instead, as one smooth [curve path](shaping.md#curve-paths). New
edges are outlines; choose another kind first in Tools → Draw As, or change an
edge's role in its properties. Outlines are what pieces are made of;
construction lines are thin, grey and dashed, and are only guides.

In desktop Design, open **Preferences → Design → Line Styles** to choose a
colour, line pattern and width for each role. **Reset this role** restores
its defaults. The Lines tab shows the same styles.

A new curve starts straight. Select it to see its handles, and drag a handle's
end to shape it, or type its angles and lengths in the properties. Tools →
Edge → Change to Curve and Change to Line turn one into the other in place.
A line that is a piece's fold, or whose part is, stays a line: a fold has to
be straight.

## Moving points

Drag a point with the Select tool, or nudge the selected points with the arrow
keys: 1 mm a press, 10 mm with ++shift++. Only plain numbers change: a point
with one formula moves along its other number only, so a point whose x is a
formula moves up and down along a dashed guide. A point placed only by
formulas, or by other objects, stays put and the status bar says why. Change
its formulas in the Properties tab instead.

## Locking objects

Lock a finished part of a pattern so it can't be changed by accident: select
the objects and choose Edit → Lock, or tick Locked in the Properties tab.
A locked object is drawn greyed. You can still select it, copy it and draw
from it, and its formulas still work: when a measurement or a variable it
uses changes, it moves as usual.

What you can't do is move it, change its formulas, name or settings, or
delete it; the Properties tab shows its values without letting you edit
them, and the status bar says why when something is refused. Anything else
that would change it is refused too, such as splitting one of a locked
piece's edges or adding a notch to it. A line drawn inside a locked piece
isn't added to it as a marking.

Edit → Unlock, or clearing Locked, makes it editable again. Locking and
unlocking are each one undo step, and the lock is saved with the pattern. A
pasted copy of a locked object starts unlocked.

## Bisecting a corner

Drafting instructions often say to bisect a corner and mark a distance along
the bisector, such as 2.5 cm into the corner of an armhole. There is no
separate command for it: make an offset point from the corner, and give it the
distance as its Length and the bisector's direction as its Angle.

The direction is `bisect` of the two sides' directions, which gives the
direction halfway between them. Each side must point away from the corner. A
line's angle runs from its start to its end, so add 180 to a line that ends
at the corner. For a corner at A between `Chest_line`, drawn from A, and
`Side_line`, drawn to A:

```
bisect(Chest_line.angle, Side_line.angle + 180)
```

The point stays on the bisector when the measurements move the lines.

## Other operations

| Command | Makes |
| --- | --- |
| Tools → Arc | An arc around a selected point |
| Tools → Edge → Split Edge | Two parts of an edge, split at a point on it; pieces and seams that used the edge take the parts |
| Tools → Edge → Round Corner | An arc rounding the corner where two selected edges meet |
| Tools → Offset | A line following an edge, or a run of edges, at a distance: stitch lines, facings |
| Tools → Points → Merge Points | One point from several, which everything that used them then uses |
| Tools → Points → Break Point | One point for each edge that meets at a point |
| Tools → Points → Change To | The first selected point placed another way, from the other selected objects; see [Point types](points.md#changing-a-points-type) |
| Tools → Points → Repeat Points | A row of evenly spaced points between two selected points or along a selected edge |
| Tools → Transform | Rotated, mirrored or moved copies, which follow their sources |

[Curves, copies and repeats](shaping.md) explains curve paths, offsets,
rounded corners, transforms and repeats. Every operation and its settings are
listed in
[Operations and objects](../reference/operations.md).
