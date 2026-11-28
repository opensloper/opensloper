---
description: "Add a zip, dart, hem, facing or buttons to a sewing pattern in one step from the Features tab, and undo it in one step."
---

# The Features tab

The **Features** tab in the side panel adds a sewing detail to the pattern in
one step. Choose the feature, select where it goes on the canvas, check its
settings and click **Apply**. The feature is made of the ordinary points,
edges, notches and allowances you could draw yourself, so afterwards you can
change any of them as you like. One **Undo** takes the whole feature off
again.

The tab has five features, the zip, the dart, the hem, the facing and
buttons. More are planned, such as pockets.

## Zip

A zip goes along an edge of a piece, such as a centre back or a side seam.
The tutorial [Adding a zip](../tutorials/zip.md) puts one in a skirt step
by step.

1. Open the **Features** tab and choose **Zip**.
2. Click the edge on the canvas. The tab says **Along** and the edge's name.
3. Check the settings, then click **Apply**.

| Setting | What it does |
| --- | --- |
| Style | **Centred**: topstitched either side of the seam. **Invisible**: sewn from the inside, so nothing shows and no topstitching is added. **Lapped**: one side laps over the zip, stitched down beside it and across at the stop. **Fly front**: the side laps over by the fly's width, stitched down and curving in to the stop as a J, with a fly shield behind the zip |
| Length | How long the opening is. It starts as `#zip_length`, a [variable](formulas.md) that the first zip adds at 20 cm, so every zip in the pattern can share it; type a number or another formula for a different length |
| Starts from | Which end of the edge the opening starts at, such as the waist |
| Allowance along the zip | The seam allowance along the opening, usually wider than the rest of the seam so the zip tape has room. For a fly front it is the **fly extension**, which folds back to make the fly |
| Topstitching from the seam | How far in from the seam the topstitching runs: either side of a centred zip, the lap's width for a lapped zip, the fly's width for a fly front |
| Fly shield width | For a fly front, how wide the shield is once folded |

Each style starts with its own widths, in the pattern's unit: a centred zip
is stitched 7 mm from the seam with a 20 mm allowance, a lapped zip 10 mm
from it, and a fly front 30 mm from it with a 40 mm extension and a 40 mm
shield.

**Apply** then:

- adds a point, **ZipStop**, where the zip ends, the length from the end you
  chose;
- splits the edge there, so the opening and the rest of the seam are edges of
  their own, and every piece that uses the edge takes both parts;
- gives the opening its own allowance (see
  [Seam allowance](pieces.md#seam-allowance));
- notches every piece at the stop, so the two sides match;
- adds the topstitching as stitch lines inside each piece: along the opening
  for a centred zip; along it and across at the stop for a lapped zip; down
  at the fly's width and curving in to the stop for a fly front, where the
  straight part runs down a construction guide the width from the seam;
- for a fly front, adds a **FlyShield** piece to the right of the pattern:
  the zip's length and 2 cm more, cut on the fold, so it stays as long as
  the zip.

### Lapped zips and fly fronts

Only one side of a lapped zip or a fly is stitched on the outside. Apply the
style to the side that laps over, and **Invisible** to the other side, which
then gets its stop, notch and allowance with no topstitching. A front cut
twice as a mirrored pair needs only one fly: cut both with the extension, and
stitch the J on the side that laps over, as the line on the pattern shows.

A zip longer than its edge is refused, and the status bar says why.

When the edge is in a [seam](pieces.md#seams) with another piece's edge, the
status bar reminds you that the other side needs a zip too: select that edge
and click **Apply** again. Both use `#zip_length`, so they stay the same
length. A back cut twice as a mirrored pair needs only one zip, as both
copies are the same piece.

## Dart

A dart goes into an edge of one piece, such as a waist or a shoulder, and
runs into the piece to its point. The tutorial
[Adding a dart](../tutorials/darts.md) puts one in a skirt step by step.

1. Open the **Features** tab and choose **Dart**.
2. Click the edge on the canvas. The tab says **In** and the edge's name.
   To run the dart to a point you have drafted, such as the bust point,
   ++shift++ and click that point too.
3. Check the settings, then click **Apply**.

| Setting | What it does |
| --- | --- |
| Middle | How far along the edge the middle of the dart is, from the end chosen under **Starts from**. Leave it empty for halfway |
| Starts from | Which end of the edge the middle is measured from |
| Width | How wide the dart is at the edge: 2 cm to start with |
| Depth | How far the dart runs into the piece, square to the edge: 9 cm to start with. With a point selected, the dart runs to the point instead |
| Hole back from the point | How far back from the point the hole marking the dart's end goes, along its centre line: 1 cm to start with, 0 on the point, empty for no hole |
| Pressed towards | Which end of the edge the dart is pressed towards once sewn, which shapes its cap (below) |

**Apply** then:

- adds a point, **DartMid**, at the middle, and two points, **DartLeg**,
  half the width either side of it along the edge, so on a curved waist they
  stay on the curve;
- adds **DartApex**, the dart's point, at the depth from DartMid, unless you
  selected a point for it;
- adds the two legs, from the edge to the point, and splits the edge at both
  legs: in the piece's outline the legs take the place of the edge between
  them, which stays as a construction line;
- adds a [seam](pieces.md#seams) between the legs, named **Dart**, which
  checks they match and lets [the Garment tab](garment.md) close the dart;
- notches the piece at both legs;
- adds a hole near the point and draws the dart's centre line as a fold
  line;
- gives the dart a cap (below).

The dart follows what it was made from: change the width or depth formula
of the points, or move the point it runs to, and the legs, seam, hole and
cap follow.

A dart wider than its edge, or whose legs run past an end of it, is refused,
as is one with no depth, one whose point is outside the piece, one whose
legs would cross another edge of the piece, and one in a fold. The status
bar says why.

### The dart's cap

Once a dart is sewn and pressed to one side, the seam allowance across it has
to be the shape of the folded dart: a small point that sticks out from the
cutting line. Cut straight across instead, the folded dart would come up
short of the seam. The cap is worked out the way you would by hand: the dart
is folded closed and pressed, the cutting line is drawn across it, and the
dart is opened out again. Pressed one way or the other, the cap is the same
for a dart in a straight edge with the same allowance either side, and
differs when they are not.

A dart you drew yourself can have a cap too, as long as a seam joins its two
legs: select the piece, and under **Cap on** and the seam's name choose
which leg's side it is pressed towards, or None.

## Hem

A hem finishes the bottom of a skirt, a sleeve or a trouser leg. It goes
along one or more edges, on one piece or on several at once, such as the
front's and the back's hems. The tutorial [Adding a hem](../tutorials/hem.md)
hems a skirt step by step.

1. Open the **Features** tab and choose **Hem**.
2. Click the edge on the canvas, and ++shift++ and click any more: the
   front's and back's hems, or the parts of a hem split by a notch. The tab
   says **Along** and the edges' names. On each piece the edges must run end
   to end.
3. Check the settings, then click **Apply**.

| Setting | What it does |
| --- | --- |
| Style | **Single**: turned up once, the raw edge overlocked. **Double**: turned up, then turned under again, so no raw edge shows. **Narrow**: a small double hem, as on a shirt or a curved hem. **Blind**: turned up once and sewn by hand or with a blind stitch, so no topstitching is added |
| Depth, turned up | How deep the hem is once turned up. It starts as `#hem_depth`, a [variable](formulas.md) that the first hem adds at 4 cm, so every hem in the pattern shares it. A narrow hem starts at 6 mm of its own |
| Turned under besides | For a double or narrow hem, how much more turns under: 1 cm to start with |
| Topstitching from the fold | How far up from the hem's fold the topstitching runs: 3 mm short of the depth to start with, following the depth as you change it |
| Notch where it turns up | Whether to notch the edges beside the hem where it turns up |

**Apply** then, on each piece:

- gives the edges their own allowance (see
  [Seam allowance](pieces.md#seam-allowance)): the depth, or for a double
  or narrow hem the depth and the turn-under, such as `#hem_depth + 1`;
- mirrors the allowance's ends (below);
- adds the topstitching as a stitch line inside the piece, unless the hem
  is blind;
- notches the edges beside the hem at its ends, so you know where to turn
  it up.

Change `#hem_depth` under Variables and every hem made with it follows.

### Mirrored ends

Where a hem meets a side seam at an angle, as on a flared or tapered skirt,
cutting the allowance straight on would leave it the wrong shape: turned up,
its ends would stick out past the side seam or fall short of it, and the hem
would pull. Instead the hem's allowance ends are the side seam's allowance
reflected in the hem line, so turned up they lie along it. Where the hem
meets the side square, the end is the same as before.

Any edge can have mirrored ends: select the piece and choose the edge under
**Mirrored ends**. It gets a row of its own, **Ends of** and the edge's name;
choose Plain there to go back.

A hem on an edge in no piece, on a piece's fold, or on edges of one piece
that do not run end to end is refused, and the status bar says why. A hem
deeper than its piece is tall above it is made, as it can work as a facing,
and the status bar says so.

## Facing

A facing finishes a neckline, an armhole or a front opening from the inside:
a band of fabric the shape of the edge, sewn to it right sides together and
turned in. It goes along one or more edges, on one piece or on several at
once, such as the front's and the back's necklines. The tutorial
[Adding a facing](../tutorials/facing.md) faces a bodice's neckline step by
step.

1. Open the **Features** tab and choose **Facing**.
2. Click the edge on the canvas, and ++shift++ and click any more: the
   back's neck as well as the front's, or the neck and the centre front of
   an opening. The tab says **Along** and the edges' names. On each piece
   the edges must run end to end.
3. Check the settings, then click **Apply**.

| Setting | What it does |
| --- | --- |
| Width | How wide the facing is, in from the edges. It starts as `#facing_width`, a [variable](formulas.md) that the first facing adds at 6 cm, so the front's and back's facings match |
| Placement | **In place, over the piece**: the facing is drawn over the piece, as you would trace it. **Moved aside, beside the piece**: it is drawn to the right of the piece, clear of it |
| Interfacing, cut from | Ticked, an interfacing piece the facing's shape is added too, cut from the material chosen or typed. A name the pattern has no material for adds one |

**Apply** then, on each piece:

- adds the facing's inner edge, the width in from the edges, running on or
  cut back so it meets the edges either side of them, such as the shoulder
  and the centre front. A short edge that lies within the facing's width,
  such as the step back in from a button extension at the waist, is taken
  into the facing whole, and the inner edge meets the edge after it; and
  where a short step between the edges is swallowed by the width, as the
  step out to the extension at the neck, the inner edge leaves it out;
- splits those edges where the inner edge meets them, so the facing can use
  part of them; the piece keeps its shape, and a seam on them takes both
  parts;
- adds the facing, a piece named **Facing_** and the piece's name, round the
  edges, the parts beside them and the inner edge. It is cut as the piece
  is: the same material, grainline, number and mirroring, and on the fold
  when the edges run to the piece's fold;
- adds a [seam](pieces.md#seams), **FacingSeam**, joining the facing to the
  piece along the edges, so you can check they match;
- copies the piece's notches along the edges to the facing;
- where the pieces are seamed to each other along the edges beside, as the
  front and back are at the shoulder, joins their facings with a seam there
  too;
- adds the interfacing, **Interfacing_** and the piece's name, if you asked
  for one.

Moved aside, the facing is made of copies of those edges (see
[Move Copy](shaping.md)), and the inner edge on the piece becomes a
construction line, which shows where the facing lies. The copies follow the
piece, so the facing still changes with the pattern.

Change `#facing_width` under Variables and every facing made with it
follows.

Edges in no piece, or of one piece that do not run end to end, are refused,
as are edges that take in the piece's fold or go all round it (that is a
lining). A facing wider than the piece where its inner edge would meet the
edge beside it is refused too. The status bar says why.

## Buttons

Buttons and buttonholes go down a front opening, a cuff's end or a
waistband's end, evenly spaced between a first and a last. The tutorial
[Adding buttons](../tutorials/buttons.md) buttons a bodice front step by step.

1. Open the **Features** tab and choose **Buttons**.
2. Click the opening's edge on the canvas, such as the centre front. If the
   left and right fronts are separate pieces, ++shift++ and click the other
   front's edge too: the buttonholes go on the first, the buttons on the
   second. The tab says which.
3. Check the settings, then click **Apply**.

| Setting | What it does |
| --- | --- |
| Button size | Across the button. It starts as `#button_size`, a [variable](formulas.md) that the first buttons add at 15 mm |
| Button thickness | A buttonhole is the button's size and its thickness long, so the button goes through: `#button_thickness`, 3 mm to start with |
| How many | `#button_count`, 5 to start with. Change the variable and the buttons and holes follow |
| First from the … end, last from the … end | How far the top and bottom buttons are from the ends of the edge: 2 cm each to start with |
| Buttonholes | **Horizontal, square to the edge**, as on shirts and coats: each starts 3 mm past the centre front and runs into the piece, so the button sits on the centre front when buttoned. **Vertical, along the edge**, as on a placket: centred on each button |
| Add an extension this wide | Ticked, the edge is moved out by this width, the overlap the buttons need, and the old edge stays as a placement line: the centre front, where the buttons are. It starts at `#button_size`, the usual rule |

**Apply** then:

- adds **ButtonTop** and **ButtonBottom** on the edge, at the first and last
  distances;
- adds a **Buttonhole** [repeat](shaping.md#repeats) between them, `#button_count`
  points with the buttonhole marker, and a **Button** repeat with the button
  marker, on the same piece or along the other front's edge. Their points are
  [marked](pieces.md#markings) on the pieces they lie in;
- adds the extension if you asked for one: two short lines out from the
  edge's ends and a line the width out, in the edge's place in the outline,
  on both fronts if there are two. The edge becomes a placement line.

A piece cut twice, mirrored, carries both the holes and the buttons, as
commercial patterns do: you sew buttonholes on the side that laps over.

An extension usually has a facing behind it: select the neckline, the step
out to the extension and the extension's edge, and apply a [facing](#facing).
An extension narrower than half a button is made, and the status bar says it
is narrow.

An edge in no piece, or that is a fold, is refused, as are no buttons and a
first and last that leave no room between them.

### The buttonhole marker

A buttonhole is a point [marker](pieces.md#markings), as a hole or a button is. It is
drawn as a slot its size long, with a bar tack across each end; a cutting
machine cuts it as a slit. Besides its size it has an **angle**, the way it
runs, and an **offset**, how far along that its middle is from the point.
Set on a point by hand, it starts across and centred. Select the point or
repeat to change them.

## In scripts and with Claude

Each feature is a method of the [Automation API](../scripting/index.md),
named `feature_` and the feature: `feature_zip` puts a zip along an edge,
`feature_dart` a dart in one, `feature_hem` a hem along some,
`feature_facing` a facing along them and `feature_buttons` buttons down
one, with the
same settings as the tab, so the Claude tab and other assistants can add
them too. `set_dart_cap` gives a dart drawn by hand its cap, and
`set_allowance_end` mirrors any edge's allowance ends. See the
[Automation API reference](../reference/api.md).
