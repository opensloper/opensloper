---
description: "Draft a straight skirt block from four body measurements, with darts, ready to print. A first tutorial in parametric pattern drafting."
---

# A straight skirt block

This tutorial drafts a straight skirt block from four measurements: half the
back and half the front, each with a dart, made into two pieces ready to print.
On the way it covers points, lines and curves placed by formula, variables,
splitting an edge, and pieces.

The finished pattern is in the documentation's examples:
[skirt-block.sloper](../examples/skirt-block/skirt-block.sloper), with its
measurements in [skirt.slm](../examples/skirt-block/skirt.slm). Open it at any
point to compare.

!!! note "Units"

    This tutorial works in millimetres. Before you start, set Edit →
    Preferences → Unit to Millimetres, so the new pattern is in mm.

!!! tip "Point names"

    The app names each new point with the next free letter: A, B, C and so
    on. Make the points in the order the tutorial gives and their names match
    the text. Lines and curves are named after their ends, such as
    `Line_A_D`.

## 1. Measurements and variables

Save [skirt.slm](../examples/skirt-block/skirt.slm) in a folder of its own. It
holds four measurements:

| Key | Value | What it is |
| --- | --- | --- |
| `waist` | 660 | Waist circumference |
| `hip` | 920 | Hip circumference at the fullest part |
| `waist_to_hip` | 200 | Waist to hip line, at the side |
| `skirt_length` | 600 | Waist to hem, at the side |

In opensloper-design, start a new pattern (File → New), choose the measurement
file (File → Measurements → Open Set…) and save the pattern beside it as
`skirt-block.sloper`.

The block is worked out from a few values that several points share, kept as
variables. Rather than type them, take them from the finished pattern: save
[skirt-block.sloper](../examples/skirt-block/skirt-block.sloper) somewhere
else, click Import… in the Variables tab and choose it. These are added:

| Name | Formula | What it is |
| --- | --- | --- |
| `hip_ease` | `40` | Ease added round the hip |
| `waist_ease` | `10` | Ease added round the waist |
| `half_hip` | `@hip / 2 + #hip_ease / 2` | Half the hip, with its ease: the width of the block |
| `back_hip` | `#half_hip / 2 - 10` | The back's width at the hip; the side seam sits 10 mm towards the back |
| `front_hip` | `#half_hip - #back_hip` | The front's width at the hip |
| `suppression` | `(@hip + #hip_ease - @waist - #waist_ease) / 2` | How much the half skirt narrows from hip to waist |
| `side_take` | `#suppression / 4` | Taken in at the side seam, on each piece |
| `back_dart` | `#suppression * 0.3` | Width of the back dart |
| `front_dart` | `#suppression * 0.2` | Width of the front dart |

The suppression is shared out: a quarter at each side seam, 30% in the back
dart and 20% in the front dart. To change one, click its Formula cell and
type; Add makes a new variable of your own.

## 2. The frame

The frame is a rectangle as wide as the block and as long as the skirt, with
the waist at the top, the hip line and the hem.

1. Choose the Point tool (++p++) and click to make the first point, **A**. In
   the properties, set X and Y to `0`. It is the waist at centre back.
2. Click straight below A, about 200 mm down: the status bar says
   *New point … below A*. This makes **B**, an offset point measured from A,
   the hip at centre back. Its Length is the distance you clicked. Rather
   than type the formula, click the wand button, **f**, at the right of
   Length: a list opens of formulas close to that length. Choose
   `@waist_to_hip` and B moves to exactly 200 mm below A.

    If `@waist_to_hip` is missing from the list, keep the wand open and drag
    B closer to 200 mm below A. The suggestions update as you drag. See
    [Formula suggestions](../design/formulas.md#formula-suggestions).

3. Click further below A, about 600 mm down, for **C**, the hem at centre
   back, and take `@skirt_length` from the wand in the same way.
4. Click level with A, to its right, for **D**, the waist at centre front.
   Its length is a variable: type `#half_hip` in Length. After `#` the field
   lists the variables to choose from, so there is little to type.
5. Click right of B for **E**, and right of C for **F**, each with Length
   `#half_hip`.

Now the lines. With the Line tool (++l++), click A then D: the clicks snap to
the points you made, and the line is named `Line_A_D`. Set its Role to
Construction in the properties, since it is only a guide. Then draw:

| Line | From | To | Role |
| --- | --- | --- | --- |
| `Line_B_E` | B | E | Construction |
| `Centre_back` | A | C | Outline |
| `Centre_front` | D | F | Outline |
| `Line_C_F` | C | F | Outline |

Name the two centre lines **Centre_back** and **Centre_front** in the
properties: later steps fold and sew along them, and a name says which is
which.

![The frame](images/skirt-1-frame.svg){ .draft }

Change a measurement in the Measurements tab and click Save, or try the slider
at the bottom of it, and the frame follows.

## 3. The side seam

The side seam sits at the back's width from centre back, and goes in at the
waist by the side take.

With the Point tool, click on `Line_B_E` a little left of its middle, nearer
B. This makes **G**, a point along the edge, measured from its nearer end.
Open the wand beside its Distance or ratio and choose `#back_hip`. Do the
same on `Line_C_F` for **H**: type `#back_hip`, or take it from the wand.

On the waist line, `Line_A_D`, make **I** nearer A, with Distance or ratio
`#back_hip - #side_take`, and **J** nearer D, with `#front_hip - #side_take`.
J is measured from D, the end it is nearer, so the front is measured from
centre front.

With the Curve tool (++c++), draw a curve from I to G, the back's hip, and one
from J to G, the front's. Select each and set its handles, so the seam curves
out over the hip and runs straight down below it:

| Curve | Start angle | Start handle | End angle | End handle |
| --- | --- | --- | --- | --- |
| `Curve_I_G` | `275` | `@waist_to_hip / 3` | `90` | `@waist_to_hip / 3` |
| `Curve_J_G` | `265` | `@waist_to_hip / 3` | `90` | `@waist_to_hip / 3` |

Angles point the way the handle goes: 270 is straight down, and the end angle
points back along the curve, so 90 is straight up. Finally draw the line
`Line_G_H` down the side.

The hem is still one edge, and a piece is made of whole edges, so split it
where the side seam meets it: select `Line_C_F` and H, then Tools → Edge →
Split Edge. The hem is now two parts, `Line_C_H` and `Line_H_F`.

![The side seam](images/skirt-2-side.svg){ .draft }

## 4. The darts and the waist

Each dart is centred on its half of the waist, with its two sides half the
dart's width either side of the centre. All six points are on the waist line,
measured from centre back (A) for the back dart and centre front (D) for the
front: click nearer the end they are measured from.

Make the back dart first, its three points on the waist and then its point:

| Point | Distance or ratio | Measured from |
| --- | --- | --- |
| K, the back dart's centre | `(#back_hip - #side_take) / 2` | A |
| L | `(#back_hip - #side_take - #back_dart) / 2` | A |
| M | `(#back_hip - #side_take + #back_dart) / 2` | A |

Click a little away from points already there, or the click reuses them, and
then type the distance. Then click straight below K for **N**, the dart's
point, with Length `140`.

The front dart the same way:

| Point | Distance or ratio | Measured from |
| --- | --- | --- |
| O, the front dart's centre | `(#front_hip - #side_take) / 2` | D |
| P | `(#front_hip - #side_take - #front_dart) / 2` | D |
| Q | `(#front_hip - #side_take + #front_dart) / 2` | D |

and **R** straight below O, Length `90`.

Draw the dart's sides as outlines, L to N and N to M at the back, P to R and
R to Q at the front, then the waist between the darts:

| Line | From | To |
| --- | --- | --- |
| `Line_A_L` | A | L |
| `Line_M_I` | M | I |
| `Line_J_Q` | J | Q |
| `Line_P_D` | P | D |

![The darts and the waist](images/skirt-3-darts.svg){ .draft }

## 5. Pieces

Choose the Piece tool (++k++) and click inside the back, then inside the
front. Each piece is made from the outlines around the click; the construction
lines are left out. Name them **Back** and **Front** in the properties: the
names are printed on the pieces.

- The back is cut twice, as a left and a right: select Back and set Cut to `2`
  and tick Mirrored.
- The front is cut once on the fold at centre front: select Front and choose
  Centre_front under Fold. Its allowance there drops to nothing and the label
  reads *Front, cut 1 on fold*.
- Mark the hip on the side seam: choose the Notch tool (++t++) and click on G
  where it meets `Line_G_H`. The notch goes on both pieces, so they match when
  sewn.

Both pieces start with a 10 mm seam allowance and a grainline straight down.

![The finished pieces](images/skirt-4-pieces.svg){ .draft }

## 6. Seams

Seams say which edges are sewn together, so the app checks their lengths and
the [drape app](../drape/index.md) knows what to sew.

Choose the Seam tool (++e++). The side seam runs over two edges on each piece,
the hip curve and the straight edge below it, and the straight edge is shared:
click on its front side to pick the front.

- Side seam: click `Curve_J_G`, then `Line_G_H` on the front side, press
  ++tab++, click `Curve_I_G`, then `Line_G_H` on the back side, and press
  ++enter++. Name it **Side** in the Objects tab.
- Centre back: the two backs are sewn along Centre_back. Click Centre_back,
  press ++tab++, click it again, and press ++enter++; name it
  **Centre_back_seam**. Both copies' edges run the same way, from the waist
  down, so press **Flip** in its properties to pair waist with waist.
- Darts: each dart is a seam between its two legs. Click `Line_L_N`, ++tab++,
  `Line_N_M`, ++enter++ for **Back_dart**, and `Line_R_Q`, ++tab++,
  `Line_P_R`, ++enter++ for **Front_dart**.

Every side matches its partner, so the status bar shows no problems.

## What next

- Change the measurements, or the ease, and watch the whole block follow.
- Open File → Publish… to lay the pieces out and print them.
- Open File → Drape… to see the skirt on a body and drape it in Blender: the
  example's drape file, beside the pattern, has the pieces placed already.
- Read [Measurements and formulas](../design/formulas.md) and
  [Pieces](../design/pieces.md) for more on each step.
