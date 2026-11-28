---
description: "Place pattern pieces round the body for draping, starting from a guess and adjusting each piece."
---

# Place pieces

A new drape places every piece by a guess, and Pieces → Guess Placements
(++ctrl+g++) does the same for pieces not yet placed:

1. The largest piece of each pattern stands upright by its grainline in front
   of the body.
2. Each piece sewn to a placed piece goes beside it along their longest seam.
3. The second of a pair cut mirrored goes as the mirror image of the first,
   on the other side of the body.
4. Pieces with no seams wait in a row beside the body.

The guess is a strip of pieces in front of the body, not a garment: wrap it
round the body by hand. Click a piece to select it, then:

| To | Do this |
| --- | --- |
| Move it across the view | Drag it |
| Move it towards or away from you | ++shift++ and drag it |
| Take it round the body, facing out | ++ctrl++ and drag it sideways |
| Turn it | Drag it with the right button: across turns it about the vertical, up and down tips it |
| Turn it in 15° steps | ++shift++ and drag with the right button |
| Turn it to face the other way | Pieces → Flip |
| Leave it out | Pieces → Unplace, or ++delete++ |

Each drag is one step to undo. The Properties tab shows where the selected
piece is as numbers you can type: its **position** in mm (X to the body's
left, Y towards its back, Z up from the floor) and its **turn** in degrees
about X, then Y, then Z. These are the numbers Blender uses for an object's
rotation.

## Align to a seam

The Properties tab lists the seams that join the selected piece to placed
pieces. Choose one and click **Align to Seam** (or double-click it) to move the
piece so its edge lies along the other piece's edge, the gap apart, as the two
would lie sewn together and opened out. **Fold Over Seam** turns it over about
the seam instead, onto the other piece. Darts are left out: the simulation
sews them shut.

## Attach an edge to the body

A garment held up only by the body can slide off it in the simulation: a
skirt that is wide at the hip, such as a circle skirt, falls past the hips to
the floor. Attach its waist to hold it there. Select the piece, and on the
Properties tab tick the edge under **Attached to the body**. Attached edges
are drawn thick and green. Each tick is one step to undo.

In Blender an attached edge starts on the body's surface, at the nearest
point to where it is placed, and stays there while the rest of the garment
is sewn and falls. Attach both halves' waists, or every piece's, as the
garment is held. With no body, an attached edge is held where it is placed,
so a bag hangs from its top edges.

An attached edge cannot move, so place it where it is once sewn. Where a seam
ends on attached edges, as a bag's side seams end at its top, those ends stay
as far apart as you placed them: put the front's and back's tops together.
Attach an edge on one side of a seam only, such as the bag's top and not its
lining's, and let the seam pull the other side to it.

