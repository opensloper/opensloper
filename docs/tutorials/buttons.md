---
description: "Add a centre-front button opening to a bodice pattern: buttons, buttonholes and extension in one step, spaced by a variable."
---

# Adding buttons

This tutorial opens the [bodice block](bodice-block.md) down the centre front
and buttons it with the Features tab: five buttons, their buttonholes and the
extension they need, in one step, and then a facing behind them. Because the
number of buttons is a variable, changing it afterwards moves and adds them
with no more work.

The finished pattern is in the documentation's examples:
[bodice-buttons.sloper](../examples/bodice-block/bodice-buttons.sloper),
beside the bodice block and its measurements in
[bodice.slm](../examples/bodice-block/bodice.slm).

## 1. Start from the bodice block

Open the bodice block you drafted in its tutorial, or download
[bodice-block.sloper](../examples/bodice-block/bodice-block.sloper) and
[bodice.slm](../examples/bodice-block/bodice.slm) into a folder of their own
and open the pattern. Save it as `bodice-buttons.sloper` in the same folder
(File → Save As…), so the block stays as it was.

The block is in centimetres, and its front is cut on the fold. A front that
buttons is cut as a pair instead, a left and a right, so open the front
first:

1. Click the **Front** piece to select it.
2. In its properties, set **Fold** to *None*.
3. Set **Cut** to `2` and tick **Mirrored**.

The front's caption now says *Front, cut 2 mirrored*.

## 2. Choose the buttons and their edge

1. Open the **Features** tab in the side panel and choose **Buttons**.
2. Click the front's centre front on the canvas, **Centre_front**. The tab
   says *Buttonholes along Centre_front*.

One piece cut twice carries both the buttonholes and the buttons, as
commercial patterns do: you sew the buttonholes on the side that laps over,
and the buttons on the other. Had the fronts been two pieces, you would
++shift++ and click the other front's edge as well, and the buttons would go
on it.

Fill in the settings:

| Setting | Value | Why |
| --- | --- | --- |
| Button size | `#button_size` | A variable the buttons add at 1.5 cm, so the buttonholes and the extension follow the button |
| Button thickness | `#button_thickness` | 0.3 cm to start with; a buttonhole is the size and the thickness long, so the button goes through |
| How many | `#button_count` | 5 to start with |
| First from the FN end | `2` | The top button 2 cm below the neckline |
| Last from the FC end | `2` | The bottom button 2 cm above the waist |
| Buttonholes | Horizontal, square to the edge | As on a shirt: the pull of the closed front runs across, along the hole, so the button stays on the centre front |
| Add an extension this wide | ticked, `#button_size` | The front laps over by one button's width, the usual rule |

Click **Apply**. The status bar says *Buttons added along Centre_front*.

## 3. What Apply made

Apply added ordinary objects, which you can change as you could any you made
yourself:

- **button_size**, **button_thickness** and **button_count**, variables under
  **Variables**.
- **ButtonTop** and **ButtonBottom** on the centre front, 2 cm from its ends.
- **Buttonhole**, a [repeat](../design/shaping.md#repeats) of five points
  between them with the buttonhole marker: a slot `#button_size +
  #button_thickness` long, 1.8 cm, with a bar tack across each end. Each
  starts 0.3 cm past the centre front, in the extension, and runs into the
  front.
- **Button**, a repeat of five points on the same places with the button
  marker, a circle with a cross the button's size.
- The extension: **Line_P_AD** out from the neck, **Offset_P_Q** down
  the front 1.5 cm out, and **Line_AE_Q** back in at the waist. They take
  the centre front's place in the front's outline.
- **Centre_front** stays, as a placement line drawn in blue, and prints on
  the front: the buttons are on it, and it is where the fronts overlap.

![The bodice with its front buttoned](images/buttons-1-front.svg){ .draft }

One **Undo** (Edit → Undo) takes all of it off again, and **Redo** puts it
back.

## 4. More buttons

Open the **Variables** tab and change `button_count` to `7`. Seven buttons
and seven buttonholes are now spaced between ButtonTop and ButtonBottom, with
nothing applied again. Change `button_size` to `2` and the buttons, the
buttonholes and the extension all grow to suit. Change them back to `5` and
`1.5`.

## 5. The buttonhole marker

A buttonhole is a point marker, as a hole or a button is. Click the first
point of the **Buttonhole** repeat and its properties show its **Marker
size** (the length), its **Buttonhole angle**, the way it runs, and its
**Buttonhole offset**, how far along that its middle is from the point. Any
point or repeat can have one: set **Marker** to *Buttonhole* and it starts
across, centred on the point.

Printed, a buttonhole is drawn as the slot and its bar tacks. A cutting
machine or laser cuts it as a slit.

## 6. A facing behind the buttons

The extension and the neckline need finishing inside, and the buttonholes
need two layers to be sewn through: a front facing does both.

1. In the **Features** tab choose **Facing**.
2. Click **Curve_W_P**, then ++shift++ and click **Line_P_AD**, the step
   out to the extension at the neck, and **Offset_P_Q**, the extension's
   edge.
3. Leave the width at `#facing_width`, tick **Interfacing, cut from** and
   leave it as `Interfacing`, then click **Apply**.

The facing's inner edge runs 6 cm in from the neckline and the extension,
from the shoulder down to the waist. At the neck it leaves out the short step
out to the extension, which lies inside the facing's width; at the waist it
runs past **Line_AE_Q**, the step back in, which the facing takes whole, and
meets the waist. **Facing_Front** and **Interfacing_Front** are cut twice and
mirrored, as the front is, and **FacingSeam** joins the facing to the
neckline and the extension. The buttonholes lie inside the facing, so they
are sewn through both layers.

The picture above shows the finished front. To try the facing on its own, see
[Adding a facing](facing.md).

## What next

- Face the back's neckline to match: select **Curve_A_G** and apply a
  facing, which shares `#facing_width` with the front's.
- Read [The Features tab](../design/features.md#buttons) for every setting
  of the buttons.
- Ask Claude in the [Claude tab](../design/claude.md) to button a pattern:
  it uses the same feature, as `feature_buttons` in the
  [Automation API](../reference/api.md).
