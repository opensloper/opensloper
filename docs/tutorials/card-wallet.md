---
title: "Draft a leather card wallet pattern"
description: "Draft a leather card wallet pattern: one piece, folded into a card pocket, with a thumb notch, rounded corners and saddle-stitched sides."
---

# A leather card wallet

This tutorial drafts a card wallet cut from leather: one piece, folded at the
bottom so a lower front makes a pocket for cards, with a thumb notch to push
them out and saddle-stitched sides. Leather is cut to the finished size and
its edges are left raw or burnished, so there is no seam allowance. On the way
it covers rounded corners, splitting an edge, a curve shaped by its handles,
a material with no allowance, stitch lines and a row of stitch holes made with
a repeat.

The finished pattern is in the documentation's examples:
[card-wallet.sloper](../examples/card-wallet/card-wallet.sloper). Open it at
any point to compare. Do the [straight skirt block](skirt-block.md) first if
you are new to OpenSloper.

!!! note "Units"

    This tutorial works in millimetres. Before you start, set Edit →
    Preferences → Unit to Millimetres, so the new pattern is in mm.

!!! tip "Point names"

    The app names each new point with the next free letter. Make the points
    in the order the tutorial gives and their names match the text. Lines and
    curves are named after their ends, such as `Line_A_B`.

## 1. Variables

Start a new pattern (File → New) and save it as `card-wallet.sloper`. The
wallet's sizes are variables: save
[card-wallet.sloper](../examples/card-wallet/card-wallet.sloper) somewhere
else, click Import… in the Variables tab and choose it. These are added:

| Name | Formula | What it is |
| --- | --- | --- |
| `width` | `100` | Width of the wallet: a card, 86 mm, with room for the stitching either side |
| `back_height` | `75` | Height of the back, from the fold to its top |
| `front_height` | `60` | Height of the front pocket, from the fold to its open edge |
| `corner` | `8` | Radius of the back's rounded top corners |
| `thumb` | `12` | Half the width of the thumb notch in the front |
| `inset` | `4` | How far in from the edge the stitching runs |
| `spacing` | `4` | Distance between stitch holes: the pricking iron's |

## 2. The outline

The piece is drafted flat: the back at the top, then the fold, then the front
below it, its open edge at the bottom.

Draw it in one go with the Line tool (++l++). Each click makes a point and
carries the line on from it:

1. Click in open space for **A**, the back's top left.
2. Click level with A, about 100 mm to its right, for **B**.
3. Click below B, about 135 mm down, for **C**: the front's open edge.
4. Click left of C, level with it and below A, for **D**.
5. Click A to close the outline.

With the Select tool (++s++), click each point and set it in the properties.
Click the wand button, **f**, at the right of a field to choose a variable or
a formula:

| Point | X and Y, or Length |
| --- | --- |
| A | X `0`, Y `0` |
| B | `#width` |
| C | `#back_height + #front_height` |
| D | `#width` |

The back's top corners are rounded, so they wear well:

1. Select `Line_D_A` and `Line_A_B` and choose Tools → Edge → Round Corner.
   An arc, `Corner_A`, replaces the corner, with points **E** and **F** where
   it meets the edges, which are cut back to them. Set its Radius to
   `#corner`.
2. Do the same at B with `Line_F_B` and `Line_B_C`, which makes `Corner_B`
   and points **G** and **H**, Radius `#corner`.

The sharp corners stay behind as construction lines, as guides.

![The outline](images/wallet-1-outline.svg){ .draft }

## 3. The fold

The fold runs across where the front ends when it is folded up. With the
Point tool (++p++), click on `Line_D_E`, the left side below the corner,
nearer D, for **I**: open the wand beside its Distance or ratio and choose
`#front_height`. Click on `Line_H_C` nearer C for **J**, Distance or ratio
`#front_height`. Then choose Tools → Draw As → Fold, draw I to J, and go back
to Outline.

## 4. The thumb notch

The notch is a dip in the front's open edge, so a thumb can push the cards up.
The edge is split either side of it, and a curve takes the middle part's
place.

1. Click on `Line_C_D` nearer C for **K**, and nearer D for **L**, each with
   Distance or ratio `#width / 2 - #thumb`.
2. Select `Line_C_D` and K, and choose Tools → Edge → Split Edge. The edge is
   now `Line_C_K` and `Line_K_D`.
3. Select `Line_K_D` and L, and split it again, into `Line_K_L` and
   `Line_L_D`.
4. Select `Line_K_L` and set its Role to Construction: the curve replaces it.
5. With the Curve tool (++c++), draw a curve from K to L, and set its handles:

| Start angle | Start handle | End angle | End handle |
| --- | --- | --- | --- |
| `90` | `#thumb` | `90` | `#thumb` |

The curve leaves K straight up, into the front, and arrives at L coming
straight down: its end angle points back along it, up. Change `thumb` and the
notch grows or shrinks.

![The fold and the thumb notch](images/wallet-2-notch.svg){ .draft }

## 5. Leather, with no allowance

In the Materials tab, click Edit…. Rename **Main** to **Leather**, give it
the colour `#8B5A2B` and the fabric Leather, and set its Allowance to `0`.
Pieces cut from it start with no seam allowance: the cutting line is the
outline.

With the Piece tool (++k++), click inside the outline and name the piece
**Sleeve**. Its cutting line is its outline, and the fold line is marked on
it.

## 6. The stitching

Each side is stitched through both layers, from the front's open edge down to
the fold and up the back the same distance, so the holes meet when the piece
is folded. The stitch line runs `inset` in from the edge.

1. Click right of I for **M**, Length `#inset`: on the fold, in from the
   left edge.
2. Click below M for **N** and above M for **O**, each with Length
   `#front_height - #inset`.
3. Click left of J for **P**, Length `#inset`, then below P for **Q** and
   above P for **R**, each with Length `#front_height - #inset`.
4. Choose Draw As → Stitch, draw O to N and R to Q, and go back to Outline.

The holes are a repeat: points evenly spaced between two points, all
marked as holes.

1. Select O, then hold ++shift++ and select N, and choose Tools → Points →
   Repeat Points. The repeat, **S**, has its first and last points on O and
   N.
2. Set its **Count** to `round(Line_O_N.length / #spacing) + 1`, so the holes
   are about `spacing` apart however long the side is.
3. Choose Hole as its Marker, with Size `1`.
4. Do the same from R to Q for **T**, with Count
   `round(Line_R_Q.length / #spacing) + 1`.

The two halves of each row are the same length either side of the fold, so
the holes on the back meet those on the front when the wallet is folded.

## 7. A note

With the Text tool (++x++), click inside the piece and type
`Punch the holes,`, `fold on the fold line` and
`and saddle stitch both sides`, on three lines. It prints with the piece.

![The finished wallet](images/wallet-3-sleeve.svg){ .draft }

## What next

- Change `width` for a wider wallet, or `front_height` for a shallower
  pocket, and watch the fold, the notch and the stitch holes follow.
- Set `spacing` to your pricking iron's spacing: the count of holes changes to
  keep them evenly spaced.
- Open File → Publish… to print the piece at full size, and cut round it.
- Read [Shaping](../design/shaping.md) for more on rounded corners and
  repeats, and [Material](../design/pieces.md#material) for materials.
