---
description: "OpenSloper's Automation API: JSON-RPC 2.0 methods to draft and change sewing patterns from a script or an AI assistant such as Claude."
---

# Automation API

!!! note

    This page is generated from the program by `opensloper-cli doc api`; do not edit it by hand.

`opensloper-cli serve` lets a script or an assistant such as Claude drive a pattern. It reads JSON-RPC 2.0 requests on standard input, one a line, and answers each on a line of standard output. Every change goes through the pattern's undo history, as an edit in the window does.

For example:

```
--> {"jsonrpc": "2.0", "id": 1, "method": "set_formula", "params": {"name": "B", "field": "length", "formula": "@waist / 4 + #ease"}}
<-- {"jsonrpc": "2.0", "id": 1, "result": {"id": 3, "name": "B", "type": "offsetPoint", ...}}
```

## Errors

A refused call answers with a JSON-RPC error. Its `data` names the `field` at fault and the `position` of the problem in a formula, when there is one. Check the code, not the message, which may be translated.

| Code | Meaning |
| --- | --- |
| -32700 | The line is not JSON |
| -32600 | Not a JSON-RPC 2.0 request |
| -32601 | There is no such method |
| -32602 | A parameter is missing or the wrong type |
| -32603 | Something went wrong inside |
| -32000 | The call was understood and refused, such as a formula with an unknown name |

## Files and history

### `open`

Opens a pattern, optionally with another measurement file and a size. A pattern given as text opens with no file and no measurements: give its measurement file, which the reply's `measurementsFile` names, to `use_measurements`.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `path` | text |  | The pattern file (.sloper); give this or text |
| `text` | text |  | The pattern file's contents, in place of a path |
| `measurements` | text |  | A measurement file to use in place of the one the pattern names |
| `size` | text |  | The size to use from a size table |

Returns: The pattern's file, measurement file and `measurementsFile`, the name the pattern records for it, relative to the pattern's folder; its unit, object and variable counts, and whether it is modified.

### `save`

Saves the pattern.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `path` | text |  | Where to save it, a .sloper file; by default, where it was opened from. A file that is not a pattern is never replaced |
| `text` | true or false |  | Gives the file's contents as `text` instead of writing a file, and counts the pattern as saved |

Returns: As `open` gives it, with `text`, the contents, when asked for.

### `convert_units`

Converts the pattern to another unit, rewriting only lengths, as one undo step. While a number's role is open nothing changes and the reply lists it; mark each and call again.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `units` | one of: `mm`, `cm`, `in` | yes | The unit to convert to |
| `marks` | list |  | The numbers the formulas leave open, each marked as a length or a number |
| `marks[].id` or `marks[].name` | number or text | yes | The object, by its ID or its name |
| `marks[].field` | text | yes | The field the number is in |
| `marks[].token` | whole number | yes | The number's token, as the reply listed it |
| `marks[].role` | one of: `length`, `number` | yes | What the number is |

Returns: `converted` true and the new `units`; or `converted` false and the `undecided` numbers, each with its object, `field`, `token`, `number`, `formula` and `position` in it.

### `undo`

Undoes the last change.

No parameters.

Returns: The pattern's file, measurement file and `measurementsFile`, the name the pattern records for it, relative to the pattern's folder; its unit, object and variable counts, and whether it is modified.

### `redo`

Redoes the change last undone.

No parameters.

Returns: The pattern's file, measurement file and `measurementsFile`, the name the pattern records for it, relative to the pattern's folder; its unit, object and variable counts, and whether it is modified.

## Measurements

### `use_measurements`

Uses another measurement file for the pattern, which records it; not an undo step. A file given as text is not written by `set_measurement`.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `path` | text |  | The measurement file (.slm); give this or text |
| `text` | text |  | The measurement file's contents, in place of a path |
| `file` | text |  | With text, the name the pattern records for the file, relative to the pattern's folder with /; by default the one it records now |

Returns: The pattern's file, measurement file and `measurementsFile`, the name the pattern records for it, relative to the pattern's folder; its unit, object and variable counts, and whether it is modified.

### `get_measurements`

Lists the current measurement set: its file, sizes and values in mm.

No parameters.

Returns: `path`, `size` and `sizes` for a size table, and `measurements`, each with `key`, `value` and `description`.

### `set_measurement`

Adds or changes one value in the measurement file, and saves the file.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `key` | text | yes | The measurement's key, such as waist |
| `value` | number | yes | The value in mm |
| `size` | text |  | For a size table, the size to change |
| `description` | text |  | Its description; by default, the one it has |

Returns: `key`, `value`, whether it was `added`, and its `oldValue` when it had one.

### `missing_measurements`

Lists what the pattern needs that the measurement set lacks.

No parameters.

Returns: `missing`, each with its `key` and the `sizes` with no value.

## Objects and variables

### `list_objects`

Lists the variables and objects with their formulas, values and state.

No parameters.

Returns: `variables` and `objects`, each as `get_object` gives it.

### `get_object`

Gives one object or variable: its name, ID, type, formulas (as shown), computed values, state and whether it is locked.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |

Returns: The object, as `get_object` gives it.

### `set_formula`

Changes one formula of an object or variable.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `field` | text | yes | The field, such as length or formula |
| `formula` | text | yes | The new formula |

Returns: The object, as `get_object` gives it.

### `rename`

Renames an object or variable; formulas that use it follow.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `newName` | text | yes | The new name |

Returns: The object, as `get_object` gives it.

### `delete`

Deletes an object or variable that nothing uses.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |

Returns: The pattern's file, measurement file and `measurementsFile`, the name the pattern records for it, relative to the pattern's folder; its unit, object and variable counts, and whether it is modified.

### `set_locked`

Locks or unlocks an object. A locked object cannot be moved, edited or deleted, but its formulas still run, so it follows what it uses; a change that would alter it is refused.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `locked` | true or false | yes | true to lock, false to unlock |

Returns: The object, as `get_object` gives it.

### `add_variable`

Adds a variable.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `name` | text | yes | Its name, used in formulas as #name |
| `formula` | formula | yes | Its formula |
| `description` | text |  | What it is for |

Returns: The object, as `get_object` gives it.

### `import_variables`

Imports the variables of another pattern file, as one undo step. A variable whose name this pattern has is kept as it is, never overwritten, and an imported formula reading it reads this pattern's one. Refused when the files are in different units.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `path` | text |  | The other pattern file (.sloper); give this or text |
| `text` | text |  | The other pattern file's contents, in place of a path |

Returns: `variables`, those added, each as `get_object` gives it; `kept`, the names this pattern has with another formula; `same`, those it has with the same formula.

## Drafting

### `add_point`

Adds a point of any type.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `type` | one of: `freePoint`, `offsetPoint`, `alongEdgePoint`, `betweenPoint`, `intersectPoint`, `circleEdgePoint`, `circleCirclePoint`, `projectPoint` | yes | The point's type |
| `name` | text |  | Its name; by default the next free one |
| the type's members | see the type | yes | The type's members, as on the [operations page](operations.md); points and edges are given by ID or name |

Returns: The object, as `get_object` gives it.

### `add_edge`

Adds an edge: a line, curve, curve path, circle, arc or offset edge.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `type` | one of: `line`, `curve`, `curvePath`, `circle`, `arc`, `offsetEdge` | yes | The edge's type |
| `name` | text |  | Its name; by default the next free one |
| `role` | one of: `construction`, `outline`, `placement`, `stitch`, `fold`, `cut`, `skive`, `edgeFinish` |  | Its role; by default construction |
| the type's members | see the type | yes | The type's members, as on the [operations page](operations.md); points and edges are given by ID or name. An offset edge's `side` may also be `inside` or `outside` a `piece` |

Returns: The object, as `get_object` gives it.

### `add_repeat`

Adds a repeat: points evenly spaced between two points or along an edge.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `a` | ID or name |  | The first point |
| `b` | ID or name |  | The last point |
| `edge` | ID or name |  | Along this edge, in place of a and b |
| `count` | formula | yes | How many points |
| `ends` | one of: `include`, `exclude` |  | Whether the ends have points of their own |
| `name` | text |  | Its name; by default the next free one |

Returns: The object, as `get_object` gives it.

### `split_edge`

Splits an edge at a point on it into two parts; pieces and seams that used it take the parts.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edge` | ID or name | yes | The edge |
| `point` | ID or name | yes | The point on it |

Returns: The two parts.

### `add_rectangle`

Adds a rectangle of four lines from a corner.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `corner` | ID or name | yes | The corner point |
| `width` | formula | yes | How far right the opposite corner is |
| `height` | formula | yes | How far down the opposite corner is |
| `role` | one of: `construction`, `outline`, `placement`, `stitch`, `fold`, `cut`, `skive`, `edgeFinish` |  | Its role; by default construction |

Returns: The four lines.

### `round_corner`

Rounds the corner where two edges meet with an arc.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edgeA` | ID or name | yes | The first edge |
| `edgeB` | ID or name | yes | The second edge |
| `radius` | formula | yes | The arc's radius |

Returns: The object, as `get_object` gives it.

### `convert_edge`

Changes an edge to a line or a curve in place, keeping its ID.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `to` | one of: `line`, `curve` | yes | What it becomes |

Returns: The object, as `get_object` gives it.

### `convert_point`

Changes how a point is placed, keeping its ID, name and users. Its numbers are worked out so it stays where it is, or moves onto its new edge, line or crossing (at most 10 mm); formulas it had are replaced.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `type` | one of: `freePoint`, `offsetPoint`, `alongEdgePoint`, `betweenPoint`, `intersectPoint`, `circleEdgePoint`, `circleCirclePoint`, `projectPoint` | yes | What it becomes, as the pattern file names it |
| `from` | list of IDs or names |  | What it is placed from, in order: offsetPoint a point; alongEdgePoint an edge; betweenPoint two points; intersectPoint two edges; circleEdgePoint the centre and an edge; circleCirclePoint the two centres; projectPoint the point and the edge. None for freePoint |
| `mode` | one of: `polar`, `cartesian`, `length`, `ratio` |  | For offsetPoint: polar, a length and angle, or cartesian, across and down (the default). For alongEdgePoint or betweenPoint: length or ratio. An offset point can change mode from the same base |
| `end` | one of: `start`, `end` |  | For alongEdgePoint: the start or end to measure from |

Returns: The object, as `get_object` gives it.

### `merge_points`

Merges two or more points into one, which every edge and formula then uses.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `points` | list of IDs or names | yes | The points |

Returns: The point kept.

### `break_point`

Breaks a point into one for each edge that meets there.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |

Returns: `points`, the points it became.

### `copy_objects`

Copies points and edges, with what they depend on, as Edit → Copy does.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `objects` | list of IDs or names | yes | The points and edges to copy |

Returns: `fragment`, the copy as text for `paste_objects`; `names`, the copied objects' names; `leftOut`, the names of those that cannot be copied.

### `paste_objects`

Pastes a copy as Edit → Paste does: into the pattern it came from, the objects join what they used there; into another, what they depend on comes too. They take new IDs, and a name already taken the next number.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `fragment` | text | yes | The `fragment` that `copy_objects` gave |

Returns: `objects`, the pasted copies of the copied objects; `renamed`, names that changed, as "A → A2".

### `arrange`

Aligns or distributes points. Points a formula places are left as they are and listed, unless named in replace.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `action` | one of: `alignVertical`, `alignHorizontal`, `distribute`, `distributeHorizontal`, `distributeVertical`, `distributeAlongEdge` | yes | What to do |
| `points` | list of IDs or names | yes | The points |
| `reference` | ID or name |  | For aligning: the point to line up with |
| `edge` | ID or name |  | For distributeAlongEdge: the edge |
| `replace` | list of IDs or names |  | Points placed by a formula to change all the same |

Returns: The names of the points `changed`, `asked` (left, as a formula places them) and `kept`.

### `add_transform`

Adds rotated, mirrored or moved copies of points and edges.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `type` | one of: `rotate`, `mirror`, `move` | yes | The transform |
| `sources` | list of IDs or names | yes | The points and edges to copy |
| `name` | text |  | The transform's name |
| `suffix` | text |  | Added to the names of the copies |
| `pivot` | ID or name |  | rotate: the point to turn about; move: a point to turn the copies about |
| `angle` | formula |  | rotate: how far to turn; mirror with axis.a only: the axis's direction; move: the direction |
| `axis` | group |  | mirror: the line to reflect in |
| `axis.edge` | ID or name |  | An edge |
| `axis.a` | ID or name |  | Or a point on the line |
| `axis.b` | ID or name |  | And a second point on it |
| `length` | formula |  | move: how far, at the angle |
| `dx` | formula |  | move: how far right, in place of length |
| `dy` | formula |  | move: how far down |
| `rotate` | formula |  | move with pivot: how far the copies turn |

Returns: The object, as `get_object` gives it.

### `set_role`

Changes an edge's role. A marking role puts it on the pieces it lies in.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `role` | one of: `construction`, `outline`, `placement`, `stitch`, `fold`, `cut`, `skive`, `edgeFinish` | yes | The new role |

Returns: The edge, as `get_object` gives it, with the `pieces` it is marked on.

### `set_marker`

Gives a point or repeat a marker; it is marked on the pieces it lies in.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `marker` | one of: `plain`, `hole`, `button`, `match`, `buttonhole` | yes | The marker |
| `size` | formula |  | Its size, a buttonhole's length; by default a size for the marker and the pattern's unit |
| `angle` | formula |  | A buttonhole's angle, the way its slot runs. Default 0, across |
| `offset` | formula |  | How far along its angle a buttonhole's middle is from the point. Default 0, centred on it |

Returns: The edge, as `get_object` gives it, with the `pieces` it is marked on.

## Pieces

### `create_piece`

Makes a piece from the closed outline around a place.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `x` | number | yes | Across, in mm, inside the outline |
| `y` | number | yes | Down, in mm |
| `name` | text |  | Its name |
| `allowance` | formula |  | Its seam allowance; by default the first material's, or a round value for the pattern's unit |

Returns: The piece, as `get_object` gives it.

### `set_edge_allowance`

Gives one edge of a piece its own seam allowance, or clears it.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `edge` | ID or name | yes | The edge |
| `allowance` | formula |  | The allowance; left out, the edge goes back to the piece's |

Returns: The piece, as `get_object` gives it.

### `set_grainline`

Sets a piece's grainline: at an angle, between two points, or none.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `angle` | formula |  | At this angle |
| `start` | ID or name |  | Or from this point |
| `end` | ID or name |  | To this one |
| `none` | true or false |  | No grainline |

Returns: The piece, as `get_object` gives it.

### `add_notch`

Adds a notch on a piece's seam line, at a point or a distance along an edge.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `point` | ID or name |  | At this point |
| `edge` | ID or name |  | Or on this edge of the piece |
| `position` | formula |  | With edge: the distance from its start |

Returns: The piece, as `get_object` gives it.

### `remove_notch`

Removes a notch.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `notch` | whole number | yes | Its number, from 1 |

Returns: The piece, as `get_object` gives it.

### `add_marking`

Marks a point or a line on a piece, or adds stitch holes along an edge.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `kind` | one of: `point`, `line`, `stitch` | yes | What to add |
| `point` | ID or name |  | point: the point or repeat |
| `edge` | ID or name |  | line, stitch: the edge |
| `spacing` | formula |  | stitch: the distance between holes |
| `size` | formula |  | stitch: the hole size |

Returns: The piece, as `get_object` gives it.

### `remove_marking`

Removes a marking.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `marking` | whole number | yes | Its number, from 1 |

Returns: The piece, as `get_object` gives it.

### `set_cut`

Sets how many of a piece to cut, and whether every other one is mirrored.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `count` | whole number | yes | How many |
| `mirrored` | true or false |  | Whether every other one is mirrored |

Returns: The piece, as `get_object` gives it.

### `set_fold`

Puts a piece on the fold of one of its straight edges, or takes it off.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `edge` | ID or name |  | The edge |
| `none` | true or false |  | Off the fold |

Returns: The piece, as `get_object` gives it.

### `set_dart_cap`

Gives a dart a cap: its seam allowance across the edge shaped as the dart lies folded, so it sews into the seam. The dart is two neighbouring edges of the piece meeting at its point.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `first` | ID or name | yes | One leg of the dart |
| `second` | ID or name | yes | The other leg |
| `towards` | one of: `none`, `first`, `second` | yes | The leg whose side the dart is pressed towards, or none to take the cap off |

Returns: The piece, as `get_object` gives it.

### `set_allowance_end`

Sets how an edge's seam allowance ends where it meets its neighbours: plain, where their cutting lines meet, or mirror, their allowance reflected in the edge, as a hem's ends are so it lies flat turned up.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `edge` | ID or name | yes | An edge of the piece |
| `end` | one of: `plain`, `mirror` | yes | plain or mirror |

Returns: The piece, as `get_object` gives it.

### `set_piece_material`

Sets the material a piece is cut from.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `material` | material ID or name |  | The material |
| `none` | true or false |  | No material |

Returns: The piece, as `get_object` gives it.

### `set_piece_fill`

Sets how a piece is filled on screen.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The piece, by its ID or its name |
| `color` | text |  | Its own colour, as #rrggbb, or empty for its material's |
| `style` | one of: `material`, `tint`, `hatch` |  | How it is filled |

Returns: The piece, as `get_object` gives it.

## Materials

### `list_materials`

Lists the materials and the cut list.

No parameters.

Returns: `materials`, each with `id`, `name`, `color`, `fill`, and `allowance`, `width`, `length` and `allowTurns` when set, and the `cutList`.

### `add_material`

Adds a material.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `name` | text |  | Its name; by default the next free one |
| `color` | text |  | Its colour, as #rrggbb |
| `fill` | one of: `tint`, `hatch` |  | How pieces of it are filled |
| `fabric` | one of: `none`, `cotton`, `silk`, `jersey`, `wool`, `denim`, `canvas`, `leather` |  | How it drapes in Blender, from the drape app; none drapes as cotton |

Returns: The materials and the cut list, as `list_materials` gives them.

### `rename_material`

Renames a material.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `material` | material ID or name | yes | The material, by ID or name |
| `name` | text | yes | The new name |

Returns: The materials and the cut list, as `list_materials` gives them.

### `set_material`

Changes a material's colour, fill, seam allowance, size or fabric. Pieces that cannot fit its size are problems.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `material` | material ID or name | yes | The material, by ID or name |
| `color` | text |  | Its colour, as #rrggbb |
| `fill` | one of: `tint`, `hatch` |  | How pieces of it are filled |
| `allowance` | number |  | A seam allowance for pieces of it, in the pattern's unit |
| `noAllowance` | true or false |  | Takes its seam allowance away |
| `width` | number |  | Its width in the pattern's unit, 0 for none, which takes the length away too; a width alone is a roll |
| `length` | number |  | The length of a sheet of it in the pattern's unit, with a width; 0 for a roll |
| `allowTurns` | true or false |  | Whether pieces may lie a quarter turn round on it, for material with no grain |
| `fabric` | one of: `none`, `cotton`, `silk`, `jersey`, `wool`, `denim`, `canvas`, `leather` |  | How it drapes in Blender, from the drape app; none drapes as cotton |

Returns: The materials and the cut list, as `list_materials` gives them.

### `delete_material`

Deletes a material; its pieces are left with none.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `material` | material ID or name | yes | The material, by ID or name |

Returns: The materials and the cut list, as `list_materials` gives them.

## Seams

### `add_seam`

Adds a seam: two runs of piece edges sewn together, whose lengths are checked.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `sideA` | list | yes | Side A, in order along the seam |
| `sideA[].piece` | ID or name | yes | The piece |
| `sideA[].edge` | ID or name | yes | The edge of that piece |
| `sideB` | list | yes | Side B |
| `sideB[].piece` | ID or name | yes | The piece |
| `sideB[].edge` | ID or name | yes | The edge of that piece |
| `name` | text |  | Its name |
| `ease` | formula |  | How much longer side B should be; by default 0 |
| `tolerance` | formula |  | How far the difference may be from the ease; by default a small value for the pattern's unit |

Returns: The object, as `get_object` gives it.

### `flip_seam`

Turns a seam's side B round, for edges sewn running the same way.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |

Returns: The object, as `get_object` gives it.

### `suggest_seams`

Suggests pairs of piece edges that look like they are sewn together, without adding them.

No parameters.

Returns: `suggestions`, each with `sideA`, `sideB`, whether the edge is `shared`, and the length `difference`.

## Features

### `feature_zip`

Puts a zip along a piece's edge, as the Features tab does, in one undo step: a ZipStop point at the zip's length, the edge split there, the opening's own allowance, a notch at the stop on every piece using the edge, the style's topstitching, and for a fly front a fly shield piece cut on the fold beside the pattern. They are ordinary objects. Its length starts as #zip_length, a variable the first zip adds. When the edge is in a seam with another edge, that side needs a zip too.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edge` | ID or name | yes | The edge the zip opens along, on one or more pieces |
| `style` | one of: `centred`, `invisible`, `lapped`, `flyFront` |  | centred: topstitched either side; invisible: no topstitching; lapped: one side over the zip, stitched down and across the stop; flyFront: stitched as a J at the fly's width, with a fly shield. Default centred |
| `from` | one of: `start`, `end` |  | The end of the edge the opening starts from. Default start |
| `length` | formula |  | The zip's length. Default #zip_length |
| `allowance` | formula |  | The allowance along the opening; for a fly front, its extension past the seam. Default the style's |
| `stitch` | formula |  | How far the topstitching is from the seam. Default the style's |
| `shieldWidth` | formula |  | A fly shield's width as worn; it is cut on the fold. Default 40 mm |

Returns: `stop`, `opening` and `rest` (the edge's two parts) and `shield` (a fly front's) as `get_object` gives them, `stitching` the topstitching's objects, `pieces` the IDs of the pieces it went into, and `otherSide`, whether a seam joins the edge to another that needs a zip too.

### `feature_dart`

Puts a dart in a piece's edge, as the Features tab does, in one undo step: a DartMid point on the edge, the points either side where its legs leave it, a DartApex point at the depth square to the edge (or the point given as `apex`), the legs in place of the edge between them in the piece's outline, a seam closing the dart, a notch at each leg, a hole near the point, the centre line as a fold, and a cap on the seam allowance across the dart. They are ordinary objects.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edge` | ID or name | yes | The edge the dart opens in, on one piece |
| `position` | formula |  | Where the dart's middle is along the edge, from the end `from` names. Default halfway |
| `from` | one of: `start`, `end` |  | The end of the edge the position is from. Default start |
| `width` | formula |  | The dart's width at the edge. Default 20 mm |
| `depth` | formula |  | How far the dart runs into the piece, square to the edge. Default 90 mm |
| `apex` | ID or name |  | A point the dart runs to instead, such as a bust point; the dart follows it |
| `holeInset` | formula |  | How far back from the point the hole goes, along the centre line; 0 puts it on the point. Default 10 mm |
| `fold` | one of: `start`, `end` |  | The end of the edge the dart is pressed towards, which shapes the cap. Default start |

Returns: `mid`, `apex`, `legs` (the two legs, the start's side first), `seam`, `hole` and `centre` as `get_object` gives them, and `piece`, the ID of the piece.

### `feature_hem`

Hems pieces along their edges, as the Features tab does, in one undo step: on each piece the edges' allowance at the hem's depth (plus the turn-under for a double or narrow hem), their allowance ends mirroring the neighbouring edges' so the hem lies flat turned up, topstitching inside the piece, and a notch at each end of the hem in the neighbouring edge. They are ordinary objects. The depth starts as #hem_depth, a variable the first hem adds, so every hem shares it; a narrow hem starts at 6 mm of its own.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edges` | list of IDs or names | yes | The edges to hem, on one or more pieces; each piece's must run end to end |
| `style` | one of: `single`, `double`, `narrow`, `blind` |  | single: turned once, the raw edge overlocked; double: turned twice; narrow: a small double hem; blind: turned once with no topstitching. Default single |
| `depth` | formula |  | How deep the hem is, turned up. Default #hem_depth, or 6 mm for a narrow hem |
| `turnUnder` | formula |  | How much a double or narrow hem turns under besides its depth. Default 10 mm |
| `stitchDistance` | formula |  | How far the topstitching is from the hem's fold. Default 3 mm short of the depth |
| `notches` | true or false |  | Whether to notch the neighbouring edges where the hem turns up. Default true |

Returns: `edges` and `stitching` (the topstitching) as `get_object` gives them, `notches` (each with its `piece` and `edge` IDs), `pieces` the IDs of the pieces hemmed, and `problems`, what is worth checking though it was done, such as a hem deeper than its piece.

### `feature_facing`

Faces pieces along their edges, as the Features tab does, in one undo step, such as a neckline, an armhole or a front opening: on each piece an inner edge at the facing's width, meeting the edges either side, which are split there; a facing piece, Facing_ and the piece's name, cut as the piece is (material, grain, count, fold); a seam joining it to the piece; the piece's notches along it; seams between facings where their pieces are seamed, as at the shoulder; and an interfacing piece if asked for. They are ordinary objects. The width starts as #facing_width, a variable the first facing adds, so every facing shares it.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edges` | list of IDs or names | yes | The edges to face, on one or more pieces; each piece's must run end to end, and not all round it |
| `width` | formula |  | How wide the facing is, in from the edges. Default #facing_width, 60 mm to start with |
| `aside` | true or false |  | Whether to draw the facing beside its piece, as Move Copy does, rather than over it. Default false |
| `interfacing` | text |  | The name of a material to cut an interfacing from, the facing's shape; a name no material has adds one. Default none |

Returns: `facings`, `interfacings` (those made), `inner` (each facing's inner edge) and `seams` (joining each facing to its piece, then the facings to one another) as `get_object` gives them, and `pieces`, the IDs of the pieces faced.

### `feature_buttons`

Puts buttons and buttonholes along a front opening, as the Features tab does, in one undo step: ButtonTop and ButtonBottom along the edge at first and last from its ends, a Buttonhole repeat between them with the buttonhole marker, a slot the button's size and thickness long, and a Button repeat with the button marker, on the same piece or along the other front's edge, and an extension if asked for, the edge becoming a placement line. They are ordinary objects, so changing #button_count moves and adds holes. The size, thickness and count start as #button_size, #button_thickness and #button_count, variables the first buttons add.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `edge` | ID or name | yes | The opening's edge on a piece, such as a centre front, for the buttonholes, and the buttons too unless `buttonsEdge` is given |
| `buttonsEdge` | ID or name |  | The other front's matching edge, for the buttons, when the fronts are separate pieces |
| `size` | formula |  | The button's size, across. Default #button_size, 15 mm to start with |
| `thickness` | formula |  | The button's thickness, which a buttonhole is longer by. Default #button_thickness, 3 mm |
| `count` | formula |  | How many buttons. Default #button_count, 5 to start with |
| `first` | formula |  | How far the first button is from the edge's start. Default 20 mm |
| `last` | formula |  | How far the last button is from the edge's end. Default 20 mm |
| `extension` | formula |  | The width of an extension added past the edge, such as #button_size. Default none |
| `direction` | one of: `horizontal`, `vertical` |  | horizontal: buttonholes square to the edge, starting 3 mm past it; vertical: along it, centred on the buttons. Default horizontal |

Returns: `top` and `bottom` (the first and last buttonholes' points), `holes` and `buttons` (the repeats) and `extension` (its edges) as `get_object` gives them, `holesPiece` and `buttonsPiece` (IDs), and `problems`, what is worth checking though it was done, such as an extension narrower than half a button.

## Notes

### `add_note`

Adds a note, free or hung from a point, edge or piece; with a leader it is a callout, and with svg a stamp: a drawing in place of the text.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `text` | text |  | The text, with draft values such as {=@waist / 4}; needed unless svg is given, as a stamp's text only names it |
| `anchor` | group |  | What it hangs from; left out for a free note |
| `anchor.point` | ID or name |  | A point |
| `anchor.edge` | ID or name |  | Or an edge |
| `anchor.piece` | ID or name |  | Or a piece |
| `anchor.position` | formula |  | With edge: how far along it, 0 to 1 |
| `x` | formula |  | A free note: its place across |
| `y` | formula |  | A free note: its place down |
| `dx` | formula |  | A hung note: how far right of what it hangs from |
| `dy` | formula |  | A hung note: how far down |
| `size` | number |  | The text size in points |
| `print` | true or false |  | Whether it prints; by default true |
| `leader` | one of: `none`, `arrow`, `dot`, `line` |  | A line to what it hangs from |
| `align` | one of: `left`, `centre`, `right` |  | How its lines line up |
| `box` | true or false |  | A white box behind it |
| `font` | text |  | The font family it prints in; empty for the default sans-serif. One not installed prints in the default font |
| `bold` | true or false |  | Bold |
| `italic` | true or false |  | Italic |
| `name` | text |  | Its name |
| `svg` | text |  | An SVG drawing's text, making the note a stamp drawn at true size from the SVG's units (pixels at 96 to the inch). Paths and shapes only: text must be converted to paths first. The reply's warnings say what was drawn differently. |
| `scale` | number |  | How much bigger than true size a stamp is drawn, from 0.01 to 100; 1 when left out |

Returns: The object, as `get_object` gives it.

### `set_text`

Changes a note's text, size, printing, leader, alignment, box or font, or a stamp's drawing or scale.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `id` or `name` | number or text | yes | The object, by its ID or its name |
| `text` | text |  | The text, with draft values such as {=@waist / 4}; needed unless svg is given, as a stamp's text only names it |
| `size` | number |  | The text size in points |
| `print` | true or false |  | Whether it prints; by default true |
| `leader` | one of: `none`, `arrow`, `dot`, `line` |  | A line to what it hangs from |
| `align` | one of: `left`, `centre`, `right` |  | How its lines line up |
| `box` | true or false |  | A white box behind it |
| `font` | text |  | The font family it prints in; empty for the default sans-serif. One not installed prints in the default font |
| `bold` | true or false |  | Bold |
| `italic` | true or false |  | Italic |
| `svg` | text |  | An SVG drawing's text, making the note a stamp drawn at true size from the SVG's units (pixels at 96 to the inch). Paths and shapes only: text must be converted to paths first. The reply's warnings say what was drawn differently. |
| `scale` | number |  | How much bigger than true size a stamp is drawn, from 0.01 to 100; 1 when left out |

Returns: The object, as `get_object` gives it.

## Checking and output

### `evaluate`

Works the pattern out again and lists its problems.

No parameters.

Returns: The problems: objects that are invalid or blocked, gaps, and seams out of tolerance.

### `check`

As evaluate, with the full report of every computed value.

No parameters.

Returns: The problems, and every object's computed values.

### `render`

Draws the pattern as SVG or as a PNG image, as the drafting window shows it.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `format` | one of: `svg`, `png` |  | svg, or png for an image; by default svg |
| `width` | whole number |  | png: the image's width in pixels, from 16 to 4096; by default 1600. Its height follows the drawing |
| `labels` | true or false |  | Name the points and pieces |
| `hiddenRoles` | list of: `construction`, `outline`, `placement`, `stitch`, `fold`, `cut`, `skive`, `edgeFinish` |  | Roles of edges to leave out |
| `annotations` | true or false |  | Whether to draw notes; by default true |
| `region` | group |  | Only this part, in mm |
| `region.minX` | number | yes | The left or top |
| `region.minY` | number | yes | The left or top |
| `region.maxX` | number | yes | The right or bottom |
| `region.maxY` | number | yes | The right or bottom |
| `garment` | true or false |  | The Garment view instead: each piece as sewn, darts closed and folds opened, shaded, arranged as on the canvas; labels, hiddenRoles, annotations and region do not apply. By default false |
| `material` | text |  | garment: only the pieces cut from this material, by name; by default all |

Returns: `format` and the `svg` text; or, for png, the `png` file as base64 and its `width`.

### `ui_state`

Gives the design window's state: its pattern file, the selection, the label mode and the part of the draft in view. Only through opensloper-cli serve --connect, with the window in automation mode.

No parameters.

Returns: `file`, `modified`, `units`, `selection` (each with `id`, `name` and `type`), `labels` and `view`, the region in view in mm (`minX`, `minY`, `maxX`, `maxY`), which `render` takes as its `region`.

### `export`

Exports a saved layout file as PDF, SVG, DXF or machine DXF.

| Parameter | Value | Required | Description |
| --- | --- | --- | --- |
| `layout` | text | yes | The layout file (.slayout) |
| `path` | text | yes | The file to write, ending in the format's extension (.pdf, .svg or .dxf) |
| `format` | one of: `pdf`, `svg`, `dxf`, `machine-dxf` |  | By default, from the file name's extension |
| `profile` | text |  | A machine profile from the settings, in place of the layout's |
| `overwrite` | true or false |  | True to replace a file already at path; without it, an existing file is refused |

Returns: The `path` written.

