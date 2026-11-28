---
description: "Place pattern pieces round a body in 3D, ready to drape in Blender's cloth simulation."
---

# The drape window

**opensloper-drape** places the pieces of one or more patterns round a body in
3D, the way they are worn, ready for draping in Blender's cloth
simulation. A drape is saved as a `.sdrape` file. It reads the saved patterns
and never changes them.

!!! note "New"
    Draping is new. It has been tried on every example pattern, and each has
    a drape file beside it to start from (see
    [Examples](blender.md#examples)); other garments may need the settings
    tuned. See
    [issue #11](https://github.com/opensloper/opensloper/issues/11).

## Start a drape

In the design app, File → Drape… (++ctrl+d++) opens the drape app with the
pattern's drape file, the file of the same name ending `.sdrape`, or starts a
new one with every piece placed by a guess. It reads the saved pattern, so an
unsaved pattern is saved first, and a changed one asks whether to save. If a
drape window already shows that file, Drape… brings it to the front.

You can also open the drape app on its own: File → New from Pattern…
(++ctrl+n++) starts a drape from a pattern, and File → Open… (++ctrl+o++) takes
a drape file or a pattern.

Then [place the pieces](placing.md) round the body and
[drape them in Blender](blender.md).

## Parts of the window

- **The view**, on the left: the body and the placed pieces. A piece seen from its wrong side is drawn paler, so one facing the
  wrong way stands out. Thin lines cross each seam between placed pieces, at
  its start, middle and end, so you can see which edges are sewn together.
- **Tabs**, on the right, one open at a time, as in the other apps:

    | Tab | What it holds |
    | --- | --- |
    | Patterns | The patterns placed, the body and its measurements, and the gap |
    | Pieces | Every piece, placed or not; double-click one not placed to place it by a guess |
    | Properties | Where the selected piece is placed and how it is turned, and the seams that join it to placed pieces |
    | Claude | Ask Claude to place the pieces (see [Asking Claude](#asking-claude)) |
    | Problems | Pieces left out, pieces gone from their pattern, seams left open, and files that cannot be read |

## The body

The body is a **figure** standing on the floor: a torso, legs, arms hanging a
little out from the sides, hands, feet and a head. Its feet point to the front,
so you can tell which way it faces from any side; View → Front looks at it
from there. It is built from a measurement set: its waist, bust, hip, neck and
high hip are as round as the measurements say, at the heights they give, and
so are its thighs, knees, calves, ankles, upper arms, elbows, wrists and head;
its arms, hands and feet are as long as measured. A measurement the set does
not have is worked out from the height.

By default the figure uses the first pattern's measurements and size. On the
Patterns tab, **Choose Measurements…** picks another measurement file, **Use
the First Pattern's** goes back, and **Size** picks the size of a size table.
**No body** leaves the figure out, for bags and other accessories.

Untick **Arms** to leave the figure's arms and hands out, as a dress form
with legs. A full skirt laid round the waist would catch on arms that hang
beside it; a skirt or trousers drape the same without them.

The **gap** is how far pieces are placed off the body and apart across a
seam, 20 mm by default, so the simulation has room to pull them in.

## Look around

| To | Do this |
| --- | --- |
| Turn the view round the body | Drag the background |
| Pan | Drag with the middle button |
| Zoom | The wheel, or View → Zoom In and Zoom Out (++ctrl+plus++, ++ctrl+minus++) |
| See everything | View → Fit Body (++ctrl+0++) |
| Look from a side | View → Front, Back, Left Side, Right Side, Top or Three-Quarter |

View → Perspective draws nearer things larger. Left and right are the body's
own: its left side is on your right when you look at its front.

## Several patterns

A drape can hold several patterns, such as a top and a skirt, or a lining
and its shell; Patterns → **Add Pattern…** adds one and places its pieces by a
guess. Seams join pieces of the same pattern only.

The drape follows its patterns: when a pattern or measurement file is saved,
the drape reads it again within a second or two. New pieces wait on the
Pieces tab, and a placed piece that is gone from its pattern is listed under
Problems. Nothing is ever written back to a pattern.

## Asking Claude

The **Claude** tab lets you ask Claude to place the pieces in your own words:
"wrap the back round to the back of the body", "which seams are left open?".
It uses the Anthropic API key set in the General tab of
**Edit → Preferences**, the same key as the design app's Claude tab (see
[Asking Claude](../design/claude.md#setting-it-up)).

Claude places, turns, flips and aligns pieces, guesses placements, attaches
edges, takes the figure's arms away or gives them back and sets the gap, as
you can on the tabs, and can look at the body and pieces as a picture.
Each change is one step on the undo history. It cannot save the drape, change
a pattern or run Blender.

Sent to Anthropic: your questions, the pieces' names and placements, the
drape's problems, and pictures of the body and pieces. Patterns are named by
their file names; folders, the measurement files' names and their values are
never sent, though the body's shape and the pieces' sizes are worked out from
them.
