---
description: "Add a dart to a sewing pattern in one step and give it a dart cap, so the seam allowance sews into the waist once the dart is pressed."
---

# Adding a dart

This tutorial adds a second dart to the back of the
[straight skirt block](skirt-block.md) with the Features tab, and gives every
dart a cap: the shape the seam allowance needs across a dart, so the dart
sews into the waist seam once it is pressed. One click of **Apply** adds the
dart's points and legs, takes the waist between the legs out of the outline,
closes the dart with a seam, notches it, marks its point and caps it.

The finished pattern is in the documentation's examples:
[skirt-darts.sloper](../examples/skirt-block/skirt-darts.sloper), beside the
skirt block and its measurements in
[skirt.slm](../examples/skirt-block/skirt.slm).

## 1. Start from the skirt block

Open the skirt block you drafted in the first tutorial, or download
[skirt-block.sloper](../examples/skirt-block/skirt-block.sloper) and
[skirt.slm](../examples/skirt-block/skirt.slm) into a folder of their own and
open the pattern. Save it as `skirt-darts.sloper` in the same folder (File →
Save As…), so the block stays as it was.

The back takes 30% of the waist's suppression in one dart, `#back_dart`
wide. On a figure with a curvier seat, one wide dart makes a point at its end;
two narrower darts shape the back more smoothly. Here the suppression is
shared between the dart there is and a new one, so the waist stays the same
size.

## 2. Make the first dart narrower

Open the **Variables** tab and change the formula of `back_dart` from
`#suppression * 0.3` to `#suppression * 0.15`. The back dart, between L and M,
narrows to half its width, as L and M are placed from `#back_dart`.

## 3. Choose the dart and the edge

1. Open the **Features** tab in the side panel and choose **Dart**.
2. Click **Line_M_I** on the canvas, the back's waist from M to the
   side at I. The tab says *In Line_M_I*.

Fill in the settings:

| Setting | Value | Why |
| --- | --- | --- |
| Middle | empty | Halfway along Line_M_I, between the first dart and the side |
| Starts from | The M end | Where the middle would be measured from, if you gave one |
| Width | `#back_dart` | The other half of the back's 30%, so the two darts take up what the one did |
| Depth | `120` | A little shorter than the first dart's 140 mm, as the second dart sits nearer the side |
| Hole back from the point | `10` | The hole that marks where to stop sewing, 10 mm back from the point, so it is hidden in the dart |
| Pressed towards | The M end | Waist darts are pressed towards the centre back |

Click **Apply**. The status bar says *Dart added in Back*.

To run a dart to a point you have drafted, such as a bodice's bust point,
++shift++ and click the point as well as the edge: the dart then runs to it
and follows it when it moves.

## 4. What Apply made

Apply added ordinary objects, which you can select and change as you could
any you drew:

- **DartMid**, a point halfway along Line_M_I, and **DartLeg** and
  **DartLeg2** half the dart's width either side of it along the edge.
- **DartApex**, the dart's point, 120 mm from DartMid, square to the waist
  and into the piece.
- The legs, **Line_DartLeg_DartApex** and **Line_DartApex_DartLeg2**. The
  waist is split at both legs: the part between them,
  **Line_DartLeg_DartLeg2**, becomes a construction line, and the legs take
  its place in the back's outline.
- **Dart**, a seam between the legs, which checks that they match and lets
  [the Garment tab](../design/garment.md) close the dart.
- A notch at each leg, and a hole at **S**, 10 mm back from the point.
- **Line_DartMid_DartApex**, the dart's centre line, drawn as a fold line.
- A cap on the back's seam allowance across the new dart (below).

One **Undo** (Edit → Undo) takes the whole dart off again, and **Redo** puts
it back.

## 5. Cap the darts drawn by hand

Look at the cutting line across the new dart: instead of running straight
over it, it rises to a small point above the dart's centre. That is the dart's
cap. Sewn and pressed, a dart folds its fabric to one side; cut straight
across, the folded dart would fall short of the waist seam. The cap is what
the cutting line becomes when you fold the dart closed, press it, cut along
the waist's allowance and open it out again, as you would by hand on paper.

The skirt's other two darts were drawn by hand, so they have no cap yet:

1. Click the **Back** piece. In its properties, under **Cap on Back_dart**,
   choose **Pressed towards Line_L_N**, the leg on the centre back side.
2. Click the **Front** piece. Under **Cap on Front_dart**, choose
   **Pressed towards Line_P_R**, the leg on the centre front side.

Each choice is one undo step, and choosing **None** takes the cap off.

![The skirt with its darts capped](images/darts-1-pieces.svg){ .draft }

The waist line here is straight, with the same allowance either side of
each dart, so a cap is the same pressed either way. On a curved waist, or
with a wider allowance on one side, the side it is pressed to changes its
shape.

## 6. Check it

Open the **Garment** tab: all three darts are closed. The status bar shows
no problems, as every dart's legs match.

## What next

- Open File → Publish… and print the back: the notches, holes and centre
  lines are on the printed pieces, and the cutting line has the caps.
- Read [The Features tab](../design/features.md#dart) for every setting of
  the dart, and [Pieces](../design/pieces.md) for allowances and seams.
- Ask Claude in the [Claude tab](../design/claude.md) to add a dart: it uses
  the same feature, as `feature_dart` in the
  [Automation API](../reference/api.md), and caps a dart with
  `set_dart_cap`.
