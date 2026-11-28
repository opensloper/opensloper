---
description: "Add a zip to a skirt pattern in one step: stop, opening allowance, notches and topstitching, all following when the zip length changes."
---

# Adding a zip

This tutorial puts a zip in the centre back of the
[straight skirt block](skirt-block.md), with the Features tab. One click of
**Apply** adds the zip's stop, splits the seam there, widens the allowance
along the opening, notches both sides and draws the topstitching. Then it
changes the zip's length, and everything the zip made follows.

The finished pattern is in the documentation's examples:
[skirt-zip.sloper](../examples/skirt-block/skirt-zip.sloper), beside the
skirt block and its measurements in
[skirt.slm](../examples/skirt-block/skirt.slm).

## 1. Start from the skirt block

Open the skirt block you drafted in the first tutorial, or download
[skirt-block.sloper](../examples/skirt-block/skirt-block.sloper) and
[skirt.slm](../examples/skirt-block/skirt.slm) into a folder of their own and
open the pattern. Save it as `skirt-zip.sloper` in the same folder (File →
Save As…), so the block stays as it was.

The skirt opens at the centre back, the edge **Centre_back**, from the waist
at A to the hem at C. The back is cut twice as a mirrored pair, so one zip
on this edge goes into both backs, and the seam **Centre_back_seam** sews
them together below it.

## 2. Choose the zip and the edge

1. Open the **Features** tab in the side panel and choose **Zip**.
2. Click **Centre_back** on the canvas. The tab says *Along Centre_back*.

The tab shows the zip's settings, each starting as a centred zip has it:

| Setting | Value | Why |
| --- | --- | --- |
| Style | Centred, topstitched either side | The usual skirt zip: the seam's two folded edges meet over the teeth, stitched down either side |
| Length | `#zip_length` | A variable the first zip adds, at 200 mm |
| Starts from | The A end | The opening starts at the waist |
| Allowance along the zip | `20` | Wider than the seam's 10 mm, so the zip tape has room |
| Topstitching from the seam | `7` | Each side's stitching, 7 mm from the seam |

Leave them as they are and click **Apply**. The status bar says
*Zip added along Centre_back*.

## 3. What Apply made

Apply added ordinary objects, which you can select and change as you could any you drew:

- **ZipStop**, a point on Centre_back the zip's length from A. Its Distance or
  ratio is `#zip_length`.
- The edge split at ZipStop: **Line_A_ZipStop** is the opening and
  **Line_ZipStop_C** the rest of the seam. The back takes both parts in its
  outline, and Centre_back_seam sews both.
- A 20 mm allowance on the opening alone: the cut line steps out from the
  seam's 10 mm at the stop. Select the back and look at its edges in the
  properties to see it (see [Seam allowance](../design/pieces.md#seam-allowance)).
- A notch at ZipStop on the back, so you know where to stop sewing the seam
  and where the zip ends. Both backs have it, as they are the same piece.
- **Offset_ZipStop_A**, a stitch line 7 mm inside the seam from the waist to
  the stop, which the back shows as a marking. It is the topstitching on one
  side; the mirrored back has its own copy, so the zip is stitched either
  side.

One **Undo** (Edit → Undo) takes the whole zip off again, and **Redo** puts
it back.

## 4. Change the length

The stop sits on the hip line, at B: the zip is 200 mm long, and so is this
skirt's waist to hip. A common skirt zip is 18 cm. Open the **Variables** tab
and change the formula of `zip_length` to `180`.

ZipStop moves up the seam, and with it the split, the end of the wider
allowance, the notch and the end of the topstitching.

![The skirt with its zip](images/zip-1-pieces.svg){ .draft }
 Every zip you add to
this pattern starts as `#zip_length`, so a zip on another piece stays the
same length; type a number or another formula in the tab's Length for one of
its own.

A zip longer than its edge is refused, and the status bar says why.

## 5. Other styles

The same steps put in the other styles; choose one before clicking **Apply**:

- **Invisible**: sewn from the inside, so it adds no topstitching. Its stop,
  split, allowance and notch are as above.
- **Lapped**: one side laps over the zip, stitched down 10 mm from the seam
  and across at the stop. Apply it to the side that laps over, and
  **Invisible** to the other.
- **Fly front**, for trousers: the side laps over by the fly's width,
  stitched down and curving in to the stop as a J, and a **FlyShield** piece
  is added beside the pattern.

When the edge is in a seam with another piece's edge, as a side seam is, the
status bar reminds you that the other side needs a zip too: select that edge
and click **Apply** again.

## What next

- Open File → Publish… and print the back: the notch and the topstitching
  line are on the printed piece.
- Read [The Features tab](../design/features.md) for every setting of each
  style, and [Pieces](../design/pieces.md) for allowances and notches.
- Ask Claude in the [Claude tab](../design/claude.md) to add a zip: it uses
  the same feature, as `feature_zip` in the
  [Automation API](../reference/api.md).
