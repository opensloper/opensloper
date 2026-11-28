---
description: "Add neck facings with interfacing to a bodice pattern in one step: inner edges, facing pieces and their seams."
---

# Adding a facing

This tutorial faces the neckline of the [bodice block](bodice-block.md) with
the Features tab: the front's and back's neck facings in one step, each with
an interfacing. One click of **Apply** draws the facings' inner edges, makes
the facing pieces, seams them to the bodice and to each other at the
shoulder, and adds the interfacings.

The finished pattern is in the documentation's examples:
[bodice-facing.sloper](../examples/bodice-block/bodice-facing.sloper), beside
the bodice block and its measurements in
[bodice.slm](../examples/bodice-block/bodice.slm).

## 1. Start from the bodice block

Open the bodice block you drafted in its tutorial, or download
[bodice-block.sloper](../examples/bodice-block/bodice-block.sloper) and
[bodice.slm](../examples/bodice-block/bodice.slm) into a folder of their own
and open the pattern. Save it as `bodice-facing.sloper` in the same folder
(File → Save As…), so the block stays as it was.

The block is in centimetres, and both halves are cut on the fold: the back
on the centre back, the front on the centre front. A neckline with no
collar needs finishing inside, and a facing is the usual way: a band the
shape of the neckline, sewn to it right sides together and turned in.

## 2. Choose the facing and its edges

1. Open the **Features** tab in the side panel and choose **Facing**.
2. Click the back's neckline on the canvas, **Curve_A_G**.
3. ++shift++ and click the front's, **Curve_W_P**. The tab says
   *Along Curve_A_G, Curve_W_P*.

Selecting both makes them one step: the facings share their width, and the
shoulder seam between the bodice pieces is made between the facings too.

Fill in the settings:

| Setting | Value | Why |
| --- | --- | --- |
| Width | `#facing_width` | A variable the facing adds at 6 cm, which both facings share |
| Placement | In place, over the piece | The facing is drawn where it lies on the bodice, as you would trace it |
| Interfacing, cut from | ticked, `Interfacing` | An interfacing the facing's shape keeps the neckline from stretching. The pattern has no material of that name yet, so Apply adds one |

Click **Apply**. The status bar says *Facing added along Curve_A_G,
Curve_W_P*.

## 3. What Apply made

Apply added ordinary objects, which you can change as you could any you made
yourself:

- **facing_width**, a variable of 6 cm, under **Variables**.
- Each facing's inner edge, 6 cm in from the neckline: **Offset_A_G** on
  the back and **Offset_W_P** on the front. Each runs on, or is cut back,
  so that it meets the shoulder and the centre line exactly.
- Points where the inner edges meet them: **AD** on the centre back and **AE**
  on the back shoulder, **AF** on the front shoulder and **AG** on the centre
  front. The shoulders and centre lines are split there; the bodice pieces
  keep their shape, and the shoulder seam takes both parts of each
  shoulder.
- Two pieces, **Facing_Back** and **Facing_Front**, round the neckline,
  the shoulder up to the inner edge, the inner edge and the centre line.
  Each is cut as its bodice piece is: the same material, the same grainline
  and once on the fold, along the part of the centre line it has.
- Two more, **Interfacing_Back** and **Interfacing_Front**, the same shape,
  cut from the new **Interfacing** material. Its pieces are listed apart
  in the cut list, and the Publish app lays them out on their own material.
- Seams: **FacingSeam** and **FacingSeam2** join each facing to its
  bodice piece along the neckline, and **FacingSeam3** joins the two
  facings at the shoulder, as **Shoulder_seam** joins the bodice. Each
  checks its sides match; the facings' shoulders match because the bodice's
  do.

![The bodice with its neck facings and interfacings](images/facing-1-pieces.svg){ .draft }

One **Undo** (Edit → Undo) takes all of it off again, and **Redo** puts it
back.

## 4. Change the width

Open the **Variables** tab and change `facing_width` to `8`. Both inner
edges move down, the points on the shoulders and centre lines with them,
and the facings, interfacings and seams follow. Change it back to `6`.

The facings follow the bodice too: change a measurement in the measurement
file and the neckline, and the facings drawn from it, change with it.

## 5. In place or beside the piece

Drawn in place, a facing lies over its bodice piece, as the bodice's fill
shows through it. That is how a drafter traces one, and it keeps the
picture of how the two go together. If you would rather see it on its own,
choose **Moved aside, beside the piece** under **Placement** before you
apply it: the facing is then made from copies of its edges to the right of
the piece, and the inner edge on the bodice becomes a construction line
marking where the facing lies. Either way, the pieces print and are laid
out apart.

A facing can go along more than one edge of a piece: the neckline and the
centre front together make the facing of a front opening. It cannot take in
the piece's fold, nor go all round it, which would be a lining.

## What next

- Open File → Publish… and lay out the pieces: the facings go on the main
  material and the interfacings on their own.
- Read [The Features tab](../design/features.md#facing) for every setting
  of the facing.
- Ask Claude in the [Claude tab](../design/claude.md) to face a pattern: it
  uses the same feature, as `feature_facing` in the
  [Automation API](../reference/api.md).
