---
description: "The point types of a parametric pattern: what each is measured from, and how to change a point's type afterwards."
---

# Point types

Every point records how it was placed: what it is measured from and how far.
That is its type, and it decides how the point moves when the measurements
change. [Snapping](drawing.md#snapping-decides-the-operation) picks the type
as you click; this page says what each type is for, and how to change a
point's type afterwards.

## The types

| Type | Placed from | Use it for |
| --- | --- | --- |
| Free point | Nothing: a place of its own | The first point of a draft, or a point not yet tied to others |
| Offset point | A point, across and down or at an angle | A point a measurement right of or below another, such as the waist from the centre front |
| Point along edge | An edge | A distance or a share of the way along a line, curve or arc: dart positions, notches |
| Point between points | Two points | A midpoint, or a share of the way between two points, without an edge between them |
| Intersection of edges | Two edges | Where two lines or curves cross |
| Circle and edge | A point and an edge | A compass step: the shoulder length from the neck point onto the shoulder line |
| Circle and circle | Two points | A point at given distances from two others |
| Point projected onto edge | A point and an edge | Square down from a point onto a line, or along an angle |

Each type's settings are listed in
[Operations and objects](../reference/operations.md#points).

The Properties tab shows what a selected point is placed from, after its
name: an offset point's **From**, the edge a point lies **Along** and the
end it is **Measured from**, and so on. These rows are for reading only; to
place the point from something else, [change its type](#changing-a-points-type).

An offset point's **Offset by** row chooses how it is placed from its base:

- **Length and angle**: a distance at an angle, 0° right and 90° up.
- **Across and down**: a distance right and a distance down.

Changing it keeps the point where it is. Its two formulas become plain
numbers, as when a point's type changes: Edit → Undo brings them back, and the
[formula suggestions](formulas.md) can find formulas for the new numbers.

## Changing a point's type

When a point was placed the wrong way, say a free point that should have been
on the side seam, change its type rather than delete it and draw it again.
The point keeps its name, its marker and everything that uses it: lines,
pieces, notches and formulas go on as before.

1. With the Select tool, click the point to change.
2. Hold ++shift++ and click what it is to be placed from, in order: for a
   point between points, the first point and then the second; for a circle
   and edge, the centre and then the edge.
3. Choose the type in Tools → Points → Change To. In the web app, choose it in
   the *Change point to…* box on the toolbar.

The menu item's hint says what to select for each type. The change is one
undo step.

### Dragging with the Point tool

A free or offset point can be placed from another point by dragging:

1. Choose the Point tool (++p++).
2. Press on the point and drag. A blue line follows the pointer, and the
   status bar says what the drop will do.
3. Let go on another point to place it across and down from that point, or
   in open space to make it a free point.

It stays where it is, and the change is one undo step. Letting go on an
edge, on the point itself or on a point that is placed from it does nothing,
and the status bar says why. Press ++escape++ during the drag to drop it.

### Where the point ends up

The new type's numbers are worked out from where the point is now, so it stays
put: a free point gets its own x and y, an offset point the distance across
and down from its base, a point along an edge the length from the nearer end,
a circle the distance from its centre. A point projected onto an edge is
square to the edge when it lies at the foot of the square, and otherwise at
the angle it lies at.

When the new type puts the point on an edge, a line between two points, a
circle or a crossing, it moves onto the nearest such place, and the status bar
says how far it moved. If that is more than 10 mm the change is refused: drag
the point closer first.

### Formulas become numbers

Formulas the point had are replaced by plain numbers, and the status bar says
so. Select the point and use the formula suggestions in the Properties tab to
turn the numbers back into formulas, such as `@waist / 4`.

A free point stays in the same place in every size. When the pattern uses a
size table, the status bar reminds you of this after making a point free: tie
it to other points again before grading.

### When it is refused

The status bar says why. A change is refused:

- when the point already has that type and is placed from the same objects;
- when what you selected doesn't fit the type, such as one edge for an
  intersection, which needs two;
- when it would be placed from something that is itself placed from the point;
- for a point of a repeat, a copy made by a transform, or an end of a rounded
  corner, which belong to what made them;
- while the point is locked.

With the Automation API, `convert_point` makes the same change; see
[Automation API](../reference/api.md).

### Changing how a point is measured

For a point along an edge or between two points, use **Measure by** in
Properties to switch between a length and a ratio. For a point along an
edge, **Measured from** switches the end. The point stays in place.

- Its formula becomes the equivalent number: a length rounded to 0.1 mm,
  0.1 cm or 0.01 in, or a ratio to four places.
- Undo restores the formula.
