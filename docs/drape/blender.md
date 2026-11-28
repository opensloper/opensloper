---
description: "Sew the placed pattern pieces round a body in Blender's cloth simulation and open the draped result."
---

# Drape in Blender

File → **Drape in Blender…** (the hanger on the toolbar) sews the placed
pieces round the body in [Blender](https://www.blender.org)'s cloth
simulation. It writes the files Blender needs beside the drape file (saving
a new drape first), then runs Blender in the background while a window shows
which frame it is at; **Cancel** stops it. When it is done, **Open in
Blender** opens the result, `skirt.blend`, to look round the garment. If
Blender stops with an error, the window shows its last lines.

Edit → Preferences → **Drape** sets which Blender to run (empty finds it on
the path, or where its installer puts it, and the tab says which it found),
the mesh spacing and how many frames to simulate. Without Blender the files
are still written, and the app says where.

From the command line, `opensloper-cli drape` writes the same files, beside
the drape file unless `-o` names the scene file, and `--run` runs Blender on
them:

```
opensloper-cli drape skirt.sdrape --run
```

| File | What it holds |
| --- | --- |
| `skirt.pieces.obj` | Each placed piece as a mesh of small, even triangles, made from its seam line (the seam allowance left out), opened out on a fold |
| `skirt.body.obj` | The body, when the drape has one |
| `skirt.blender.json` | Where each piece goes, its material and colour, its attached vertices, and which vertices each seam sews together |
| `skirt.blender.py` | The script that drapes them in Blender |

`--spacing` sets how far apart the mesh's points are, 10 mm unless given:
smaller follows curves more closely but simulates more slowly. Both sides of
a seam get the same number of points, spread evenly, so any ease is spread
along the seam as easing would. Darts are left open, for the simulation to
sew shut.

Pieces that are not placed are left out, and a seam with a copy missing on
one side is left open; the command lists both as warnings, and the drape
window's Problems tab lists them as you place pieces. A copy is sewn to the
nearest copy of the piece across each seam, so a pair cut as a left and a
right is sewn left to left however you placed them; when one side has fewer
copies, the copy placed furthest from them is the one left open. Clicking the
problem selects it. The scene file is
described on the [File formats](../reference/files.md) page.

## Draping in Blender

The script is written for Blender 5.2, and may need changes for other
versions. The drape app and `--run` always run the program's own copy of the
script, with the scene file, so a changed `skirt.blender.py` beside it is
never run for you; it is there to run yourself. **Open in Blender** opens the
result with Blender's auto-run of Python scripts off, as the file needs none.
`--run` looks for Blender on the path, never in the current folder, and on Windows and macOS
where its installer puts it; `--blender` gives the program instead. To run
the script yourself:

```
blender --background --python skirt.blender.py
```

It joins each pattern's pieces into one cloth object, with an edge between
every pair of points a seam sews, and the body pushes the cloth away.
Attached edges are pinned: onto the body, or where they are placed. Each
piece drapes as its material's **Fabric** (see
[Material](../design/pieces.md#material)): heavier or stiffer for denim,
canvas or leather, softer for silk or jersey, cotton when none is set. A
pattern's pieces are one cloth in Blender, so their stiffness follows each
piece's fabric but their weight is the average of them all. For
the first 40 frames the seams close with no gravity, so the pieces do not
fall before they are sewn; then gravity comes on and the garment settles,
up to frame 120 (`--frames` changes this). Each piece keeps its own group
of vertices and its material's colour, and the texture coordinates are the
fabric's own size in metres, so a photo of the fabric can be laid on it at
its real scale. Open `skirt.blend` in Blender to look round the garment:
it opens at the last frame, and playing it back shows the pieces being
sewn.

Simulating takes a while: at the 10 mm spacing a bodice or a tote bag takes
about a minute and a half, a straight skirt two minutes and a full circle
skirt three and a half. A larger `--spacing` is quicker for a first look.

After `--` the script takes options of its own, such as
`--frames`, `--sewing-frames`, `--mass` (each vertex's, in kg, in place of the fabrics'),
`--quality` and `--no-simulate` (set up the scene without running it);
`blender --background --python skirt.blender.py -- --help` lists them.

## Examples

Each [example pattern](../getting-started/examples.md) and tutorial pattern
in `docs/examples` has a drape file beside it, named like it, which File →
Drape… in the design app opens:

| Drape | How it is placed |
| --- | --- |
| Bodice block, bodice with curve paths | Front and back flat in front of and behind the body, at the shoulders; the simulation sews the shoulders, sides and darts |
| Skirt block | The front in front of the body and the two backs behind it, waist at the waist |
| Circle skirt | The two halves laid flat round the waist like a disc, waists attached, the figure without arms; the hem falls when gravity comes on. The waistband is left out |
| Tote bag | No body: the bag's front and back hang from their attached top edges, placed together as the sewn bag's top is, and the lining inside hangs from the seam round the top. The pocket and straps are left out |

The tote bag's outer material is canvas and its lining cotton.
