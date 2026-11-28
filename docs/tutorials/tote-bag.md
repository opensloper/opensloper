---
description: "Draft a lined tote bag pattern with boxed corners, a patch pocket and straps, sized by variables so one number makes it bigger or smaller."
---

# A tote bag

This tutorial drafts a lined tote bag with boxed corners, a patch pocket and
two straps. It needs no measurements: the bag is sized by its variables, so
changing one number makes a bigger or smaller bag. On the way it covers
drawing an outline with the Line tool alone, re-pointing a point by dragging
it, placement lines, a moved copy for the lining, rounded corners, materials,
a piece on the fold, seams and notes.

The finished pattern is in the documentation's examples:
[tote-bag.sloper](../examples/tote-bag/tote-bag.sloper). Open it at any point
to compare. Do the [straight skirt block](skirt-block.md) first if you are new
to OpenSloper: this tutorial goes faster over the same steps.

!!! note "Units"

    This tutorial works in centimetres. Before you start, set Edit →
    Preferences → Unit to Centimetres, so the new pattern is in cm.

!!! tip "Point names"

    The app names each new point with the next free letter. Make the points
    in the order the tutorial gives and their names match the text. Lines and
    curves are named after their ends, such as `Line_B_C`.

## 1. Variables

Start a new pattern (File → New) and save it as `tote-bag.sloper`.

The bag's sizes are variables. Save
[tote-bag.sloper](../examples/tote-bag/tote-bag.sloper) somewhere else, click
Import… in the Variables tab and choose it. These are added:

| Name | Formula | What it is |
| --- | --- | --- |
| `width` | `40` | Width of the bag at the top |
| `height` | `38` | Height of a body piece, before the corners are boxed |
| `gusset` | `12` | Depth of the boxed base; each corner cut-out is half of it square |
| `pocket_width` | `18` | Width of the patch pocket |
| `pocket_height` | `16` | Height of the finished pocket |
| `strap_length` | `65` | Length of each strap |
| `strap_width` | `3` | Finished width of each strap, cut four times as wide |
| `handle_gap` | `12` | Distance between the ends of a strap on the bag |

## 2. The body

The body is a rectangle with a square cut from each bottom corner. Sewn, each
cut-out's two sides are stitched together, which squares off the base: the
boxed corner.

Draw it in one go with the Line tool (++l++). Each click makes a point and
carries the line on from it. The status bar says what each click will make,
such as *New point 40 right of A*.

1. Click in open space for **A**, the top left.
2. Click level with A, about 40 cm to its right, for **B**.
3. Click below B, about 32 cm down, for **C**: where the right cut-out starts.
4. Click left of C, about 6 cm, for **D**.
5. Click below D, about 6 cm, for **E**: the base.
6. Click left of E, level with it, for **F**, about 6 cm from the left.
7. Click above F, level with D, for **G**.
8. Click left of G, below A, for **H**.
9. Click A to close the outline.

!!! tip "Level, or across and down"

    A click level with the point before, or straight above or below it, makes
    a point that distance from it, with a Length. A click anywhere else makes
    a point across and down from it, with an Across and a Down.

Now give the points their sizes. With the Select tool (++s++), click each
point and set it in the properties. Click the wand button, **f**, at the
right of a field to choose a variable or a formula:

| Point | X and Y, or Length | What it is |
| --- | --- | --- |
| A | X `0`, Y `0` | The top left |
| B | `#width` | The top |
| C | `#height - #gusset / 2` | The right side, down to the cut-out |
| D | `#gusset / 2` | Across the cut-out |
| E | `#gusset / 2` | Down to the base |
| F | `#width - #gusset` | The base |
| G | `#gusset / 2` | Up the left cut-out |
| H | `#gusset / 2` | Across to the left side |

Each point is placed from the one before, so the outline follows as you go.
Select the line from A to B and name it **Top** in the properties: later
steps measure along it.

![The body](images/tote-1-body.svg){ .draft }

## 3. Marks on the body

The straps are stitched to the top either side of the middle, a magnetic snap
goes in the middle, and the pocket is sewn on below it.

With the Point tool, click on Top:

| Point | Click | Distance or ratio |
| --- | --- | --- |
| I | nearer A | `(#width - #handle_gap) / 2` |
| J | nearer B | `(#width - #handle_gap) / 2` |
| K | a little left of the middle, so it is measured from A | `#width / 2` |

I and J are where the straps' ends go. K is the middle of the top. Click below
K for **L**, Length `4`: the snap. Then click further below K for **M**,
Length `10`: the top of the pocket, in the middle.

The pocket's outline on the body is a placement line, which prints on the piece
to show where the pocket goes. Choose Tools → Draw As → Placement, and with
the Line tool:

1. Click left of M, level with it, for **N**.
2. Click right of N, level with it and past M, for **O**.
3. Click below O for **P**, then left of P, level with it, for **Q**.
4. Click N to close the outline.

Choose Draw As → Outline again before the next step. Then set the corners'
lengths:

| Point | Length |
| --- | --- |
| N | `#pocket_width / 2`, from M |
| O | `#pocket_width` |
| P | `#pocket_height` |
| Q | `#pocket_width` |

![The marks on the body](images/tote-2-marks.svg){ .draft }

## 4. The lining

The lining is the same shape as the body. Rather than draw it again, make a
moved copy, which follows the body when a variable changes.

1. With the Select tool, click Top, then hold ++shift++ and click the body's
   seven other outline edges and point L. The copy takes the edges' end points
   with them.
2. Choose Tools → Transform → Move Copy…. The copies appear beside the body,
   named after their sources with `_t1`, such as `Top_t1` and `L_t1`.
3. In the transform's properties, set **Across** to `#width + 8` and
   **Down** to `0`.

The lining has the snap's other half, so mark it: select `L_t1` and choose
Hole as its Marker, with Size `1.5`.

![The lining](images/tote-3-lining.svg){ .draft }

## 5. The pocket and the strap

The pocket is cut on the fold at its top, so it opens out to twice its
height, with its two bottom corners rounded.

1. With the Line tool, click in open space below the body for **R**, then
   right of R for **S**, below S for **T**, left of T for **U**, and R again
   to close it.
2. Set the lengths: S `#pocket_width`, T `#pocket_height`, U
   `#pocket_width`. Name the line from R to S **Pocket_top**.
3. R is a free point, so the pocket would stay put if the body grew. Tie it
   to the body: with the Point tool (++p++), press on R and drag it onto A.
   R stays where it is, but is now placed across and down from A. Set its
   Across to `0` and its Down to `#height + 8`.
4. Select `Line_S_T` and `Line_T_U` and choose Tools → Edge → Round Corner.
   An arc, `Corner_T`, replaces the corner, with points **V** and **W** where
   it meets the edges. Set its Radius to `3`.
5. Do the same at U with `Line_W_U` and `Line_U_R`, which makes
   `Corner_U` and points **X** and **Y**. Set its Radius to `3` too.

The strap is a long strip, cut four times its finished width, folded in to the
middle and in half again:

1. With the Line tool, click level with S, about 8 cm to its right, for
   **Z**. After Z the app goes on to two letters. Click right of Z for
   **AA**, below AA for **AB**, left of AB for **AC**, and Z again to close it.
2. Set the lengths: Z `8`, AA `#strap_length`, AB `#strap_width * 4` and AC
   `#strap_length`.
3. With the Point tool, click on `Line_AC_Z` just above its middle for
   **AD**, and on `Line_AA_AB` just above its middle for **AE**, each with
   Distance or ratio `#strap_width * 2`: they are measured from Z and AA.
5. Choose Draw As → Fold, draw AD to AE, and go back to Outline.

![The pocket and the strap](images/tote-4-pocket.svg){ .draft }

## 6. Materials and pieces

The bag is cut from canvas, and the lining from a lighter cotton. In the
Materials tab, click Edit…:

- Select **Main** and choose Canvas as its fabric, for draping.
- Click New for a second material. Name it **Lining**, colour `#C9A66B`, fill
  Hatch, fabric Cotton.

With the Piece tool (++k++), click inside the body, the lining, the pocket and
the strap, and name them **Body**, **Lining**, **Pocket** and **Strap**. Each
starts with a 1 cm seam allowance. Then, in each piece's properties:

| Piece | Set |
| --- | --- |
| Body | Cut `2` |
| Lining | Cut `2`, Material Lining |
| Pocket | Fold: Pocket_top. Its label reads *Pocket, cut 1 on fold* |
| Strap | Cut `2`, Allowance `0`, Grainline angle `0`, along the strap |

The placement lines inside the body and the fold line down the strap become
the pieces' markings by themselves, and the hole marks the lining. With the
Notch tool (++t++), click on I and on J on the body's top, so the straps'
ends are marked on the cutting line.

## 7. Seams

Seams say which edges are sewn together, so the app checks their lengths and
the [drape app](../drape/index.md) knows what to sew. With the Seam tool
(++e++), click side A, press ++tab++, click side B, press ++enter++, and name
each seam in the Objects tab:

| Seam | Side A | Side B |
| --- | --- | --- |
| Sides | `Line_H_A` | `Line_B_C` |
| Base_seam | `Line_E_F` | `Line_E_F` |
| Corner_left | `Line_F_G` | `Line_G_H` |
| Corner_right | `Line_C_D` | `Line_D_E` |
| Top_seam | `Top` | `Top_t1` |

The two body pieces are sewn to each other at the sides and base, so each
edge is sewn to its copy on the other piece. The corners are each sewn across,
and the top of the bag is sewn to the top of the lining. Make the lining's
own seams the same way, from its copies: **Lining_sides**,
**Lining_base**, **Lining_corner_left** and **Lining_corner_right**.

Every seam's sides match, so the status bar shows no problems.

## 8. Notes

With the Text tool (++x++), click inside each piece and type its note. Each
hangs from its piece and prints with it:

| Piece | Note |
| --- | --- |
| Body | `Finished size` and, on the next line, `{=#width} × {=#height - #gusset / 2} × {=#gusset} cm` |
| Lining | `Magnetic snap at the hole` |
| Pocket | `Turn in the sides and base,`, `fold at the top and topstitch` and `to the bag at the placement lines`, on three lines |
| Strap | `Fold the long edges to the centre line, then in half, and topstitch` |

The `{= }` parts are worked out from the pattern, so the body's note reads
*40 × 32 × 12 cm* and follows the variables.

![The finished pieces](images/tote-5-pieces.svg){ .draft }

## What next

- Change `width`, `height` or `gusset` and watch every piece, the pocket's
  place and the finished size follow.
- Open File → Publish… to lay the pieces out on the canvas and the lining,
  and print them.
- Open File → Drape… to see the bag sewn up: the example's drape file, beside
  the pattern, has the pieces placed already.
- Read [Shaping](../design/shaping.md) for more on transforms and rounded
  corners, and [Pieces](../design/pieces.md) for folds and seams.
