---
description: "Hem a skirt pattern in one step as a double hem: allowance, shaped ends, topstitching and notches on the front and back together."
---

# Adding a hem

This tutorial hems the [straight skirt block](skirt-block.md) with the
Features tab: the front's and back's hems in one step, as a double hem. One
click of **Apply** gives both hems their allowance, shapes its ends, adds the
topstitching and notches where the hem turns up.

The finished pattern is in the documentation's examples:
[skirt-hem.sloper](../examples/skirt-block/skirt-hem.sloper), beside the
skirt block and its measurements in
[skirt.slm](../examples/skirt-block/skirt.slm).

## 1. Start from the skirt block

Open the skirt block you drafted in the first tutorial, or download
[skirt-block.sloper](../examples/skirt-block/skirt-block.sloper) and
[skirt.slm](../examples/skirt-block/skirt.slm) into a folder of their own and
open the pattern. Save it as `skirt-hem.sloper` in the same folder (File →
Save As…), so the block stays as it was.

The block has a 10 mm allowance all round, the hem included. That is too
little to turn up: a straight skirt wants a hem of about 4 cm, so it hangs
well and can be let down later.

## 2. Choose the hem and its edges

1. Open the **Features** tab in the side panel and choose **Hem**.
2. Click the back's hem on the canvas, **Line_C_H**, from the centre back
   at C to the side at H.
3. ++shift++ and click the front's hem, **Line_H_F**, from the side to the
   centre front at F. The tab says *Along Line_C_H, Line_H_F*.

Selecting both hems makes them one step, and they share their depth.

Fill in the settings:

| Setting | Value | Why |
| --- | --- | --- |
| Style | Double, turned twice | The raw edge turns under, so nothing frays and no overlocking shows inside |
| Depth, turned up | `#hem_depth` | A variable the hem adds at 40 mm, which both pieces share |
| Turned under besides | `10` | The 10 mm that turns under first, inside the hem |
| Topstitching from the fold | `#hem_depth - 3` | Just short of the turned-under edge, so the stitching catches it |
| Notch where it turns up | ticked | A notch in the centre back and the side seam marks the fold |

Click **Apply**. The status bar says *Hem added along Line_C_H, Line_H_F*.

## 3. What Apply made

Apply added ordinary objects and settings, which you can change as you
could any you made yourself:

- **hem_depth**, a variable of 40 mm, under **Variables**.
- Each hem has its own allowance, `#hem_depth + 10`: 50 mm, the depth and
  the turn-under. Click the **Back** piece and the row
  **Allowance, Line_C_H** shows it.
- Each hem has mirrored ends: **Ends of Line_C_H** in the back's
  properties says *Mirrored* (below).
- Two stitch lines, **Offset_H_C** and **Offset_F_H**, 37 mm up from each
  hem inside the piece.
- Notches: on the back in the centre back and the side seam, on the front
  in the side seam, where the hem line meets them. The front's centre front
  is a fold, so it has none.

![The skirt with its hem](images/hem-1-pieces.svg){ .draft }

One **Undo** (Edit → Undo) takes the whole hem off again, and **Redo** puts
it back.

## 4. Change the depth

Open the **Variables** tab and change `hem_depth` to `50`. Both hems'
allowances grow to 60 mm, and both stitch lines move up with them, as they
are worked out from `#hem_depth`. Change it back to `40`.

## 5. Mirrored ends

On this skirt the side seam meets the hem square, so the ends of the hem's
allowance run straight down, as any corner would. On a flared or tapered
skirt they would not. Turned up, a hem lies over the skirt above it; where
the side seam slopes out to the hem, the skirt is narrower above the hem
than at it, and an allowance cut straight on from the side seam would stick
out past it and pull.

A hem's ends are therefore the side seam's allowance reflected in the hem
line, so that turned up they lie along it. You can see it on any skirt with
a sloping side: the cutting line turns back in below the hem. Any edge can
have mirrored ends under **Mirrored ends** in its piece's properties, and
**Ends of** and the edge's name takes them off again.

## What next

- Open File → Publish… and print the pieces: the hem's allowance, notches
  and stitch lines are on them.
- Read [The Features tab](../design/features.md#hem) for every style and
  setting of the hem, and [Pieces](../design/pieces.md#seam-allowance) for
  allowances.
- Ask Claude in the [Claude tab](../design/claude.md) to hem a pattern: it
  uses the same feature, as `feature_hem` in the
  [Automation API](../reference/api.md), and mirrors an edge's ends with
  `set_allowance_end`.
