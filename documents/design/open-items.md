# Open items

Part of the [OpenSloper design](../opensloper-design-document.md). Everything not built yet, so each can become a GitHub issue; the other design files describe only what is built. When an item gets an issue, put its number here; when it is built, take it out and describe it where it belongs.

## Roadmap

1. **Web version**: the engine in WebAssembly under a TypeScript editor, with a Django server (see [Web version](web-version.md)). The Design and Publish apps are a beta at opensloper.com/design/ and /publish/, served by the Django site in `site/`; the Measurements app (#84), then accounts and subscriptions, are next. The web Publish app has every side panel tab but Claude's; its Patterns tab records an added file by its name rather than its path from the layout. Machine DXF stays a desktop export. A marketplace for sellers' patterns is postponed until the editor exists, as it would make the site host user content. Encrypted sync, files encrypted in the browser with a key from the user's passphrase so the server holds blobs it cannot read, is the way to offer sync and backup later if users ask for it; whether that is still personal data under PDPA is for a lawyer, and a lost passphrase loses the files. The web editor's Save as into another folder keeps the measurement file's path as the pattern recorded it, where the desktop works it out again from the new place; the editor could do so when a granted folder holds both files.

A community release follows once the apps prove easy to use.

## To do

Agreed, but not built.

**General**

- **Translation**, for the community release (see Translation in the overview).
- **One source for the web apps' text** (#156): the web's strings served by the engine from the Pascal `resourcestring`s, so translation is done once. After the web Measurements app (#84) and 0.9.0.
- **Release signing** (#17): macOS notarisation, Intel macOS builds and signed Windows programs.
- **More tutorials** (#46): moving a dart, a tote bag, a leather card wallet.
- **Help in the apps** (#32): F1 and the Help menu open the page for the current tool or dialog through a table of help IDs. Translated and versioned documentation wait for the community release.

**Web Measurements app** (#84)

At `/measurements/`, built in small pull requests as the web Publish app was, each one usable.

- **As the desktop's** `Sloper.Measurements.MainForm`, one window: Name and Notes above a table with a column per size, beside the catalogue and the body figure. The web modules are named after it and its units.
- **Editing stays in Pascal**: `TMeasurementDocument` behind `measurements_` methods in their own table, reached through `TEditorApiServer`, so the three pages share one engine module.
- **Shared parts**: the list grid, `STRINGS`, the engine's shortcut tables, `FileAccess`, `Autosave` and the service worker.
- **#111 is the reference** for the document from text, the pattern check and the catalogue figure, and is credited where its ideas are used.

1. **Open**: built (see [Web version](web-version.md)).
2. **The table**: built.
3. **Size tables**: built.
4. **Name and Notes**: built.
5. **The catalogue and the body figure**: built.
6. **Check Against Pattern**: built.
7. **Files**: built.
8. **Import and Export** of Seamly2D and Valentina files: built.
9. **The site**: linked from the home page, the footer and the sitemap, with a CHANGELOG entry and a section in the user guide.

Then #156 moves the three web apps' text to the Pascal `resourcestring`s.

**Design app**

- **Transforms** (#49): a live ghost while dragging, and snapping to existing angles.
- **Preferences in the web editor**: the grid's step per unit, whether the rulers show (kept between visits; for now they show at each start) and printer calibration, kept in the browser.

**Publish app**

- **`set_output` as the Output tab**: the layout server's `set_output` (the assistant and the API) should change the output through `TLayoutDocument.ChangeOutput`, as the desktop and web Output tabs do, so it also resets the pages left out and takes a material's size.
- **True-shape material needed**: the estimate still packs bounding boxes; nesting needs its fold halves and mirrored pairs as shapes.
- **Raising the publish window on Wayland** (#59), which needs an `xdg-activation` token Qt 5 cannot use.

**Drape app**

- **Attaching points** (a strap's end, a button) as well as edges.
- **The user's own body**: a mesh from MakeHuman / MPFB, a scan or a modelling app.
  - For a real person, scaling it so its height matches `height` is enough.
  - A game or film character is often stylised, so the body is also **measured to make a measurement set**.
  - Each girth is the perimeter of the convex hull of a horizontal cut through the mesh, where a tape measure would sit.
  - The levels come from the armature's bones where there is one (hips, spine, neck, shoulders), else from markers the user places. Lengths are measured along the surface between levels.
  - The result is a `.slm` with the catalogue's keys, or one column of a size table, so a cast of characters becomes one size table.
  - A measurement that cannot be taken is left empty and listed.
  - The pattern then fits the character, and the character's own mesh is the collision body in Blender.
- **UVs for game assets.** Texture coordinates are the piece's frame in metres. An export option sets them otherwise: `--uv=frame|grain|packed|udim` on `opensloper-cli drape`, and in the drape app's Preferences.
  - `grain` turns each piece's UVs so its grainline runs along V, so a fabric texture follows the grain.
  - `packed` also packs every copy into the 0–1 square with the publish app's packing. Every piece has one scale, so texel density is even.
  - `udim` gives each material its own UDIM tile.
  - Mirrored copies keep their own UV islands, so a texture is not mirrored on them.
- **Draping into the user's own scene.** An artist's character lives in their own `.blend`.
  - The script gains `--into FILE.blend` and `--body-object NAME`.
  - It opens that file with `--disable-autoexec` and uses the named object as the collision body, in place of `NAME.body.obj`.
  - It adds the cloth objects and saves to `--output`, never over the file it opened.
  - Nothing from the drape's folder is run, as before: the `.blend` is opened as data, and its Python does not run.
- **Re-draping in place.** After a pattern or measurement change, draping again into the same `.blend` replaces the cloth objects and keeps the materials the artist gave them. Cloth objects are matched by their source's name, as there is one per source, and materials by piece.
- **Every size at once.** `opensloper-cli drape DRAPE --sizes=all` drapes once per column of the body's size table, writing `NAME-SIZE` files.
  - It is for a crowd of characters, or a character creator's body types.
  - Placements carry over because anchors are computed.
  - A size where a seam is left open or a copy has failed is reported and skipped.
- **Arrangement zones** (#202). The generated body gives named zones, computed from the measurements like the body itself.
  - The zones: `torso_front`, `torso_back`, `torso_left`, `torso_right`, `arm_left_front`, `arm_left_back`, `arm_right_front`, `arm_right_back`, `leg_left_front`, `leg_left_back`, `leg_right_front`, `leg_right_back`.
  - A torso or leg zone is part of the lofted ellipse rings. An arm zone is the same around the arm's axis, which hangs at `ARM_ANGLE`.
  - A placement can name a zone instead of a free `position`, with:
    - `level`: a height on the body, as a formula (`@waist_height`, or a named body level; see Open questions). For an arm or leg, it is a distance along the limb's axis from the shoulder or the crotch.
    - `around`: the angle around the body from the zone's centre, in degrees, default 0.
    - `clearance`: the distance outside the body surface, default the drape's gap (20 mm).
    - `spin`: the piece's rotation in its own plane, in degrees, default 0, so a bias-cut piece can be placed on the bias.
    - `wrap`: true by default. The piece is curved around the body.
  - The anchor goes to the zone point at `level` and `around`, pushed out by `clearance`.
  - With `wrap`, the exporter bends the piece mesh around the ring at the anchor's level, grown outward by `clearance`.
    - Each vertex's drafted x becomes an arc length around that ellipse (found numerically). Drafted y stays vertical, or follows the limb's axis.
    - This is a cylinder bend, so lengths along and across the piece stay the same, and seam lengths do not change.
    - A piece wider than half the ring is bent only over the half facing the zone. The rest stays flat and tangent, so a full skirt does not overlap itself.
  - A wrapped copy is written in world coordinates with zero `location` and `rotation_euler`, and marked `"wrapped": true` in `NAME.blender.json`.
    - The flat mesh goes in as a shape key named `Flat`, and the cloth's rest shape key is set to it. Blender then treats the flat piece as the rest state and the curve only as the starting state.
    - UVs are still the flat piece frame.
  - Zones are computed, so a placement still fits after a measurement change, or for every size in a table.
  - Free placements stay for anything zones do not cover: bags, hats, a body with no arms.
  - **Guess Placements** chooses a zone for each copy instead of making a strip. Mirrored pairs go left and right. A piece sewn to both sides of the body goes front or back.
  - Pieces start close to their seam partners and already curved, so the gravity-off sewing phase should be able to get shorter. `--sewing-frames` stays so this can be tested.
- **Fit maps** (#202). The drape result comes back to OpenSloper as two maps for each copy.
  - **Stretch.** For each triangle, the rest triangle (2D, flat piece) is compared with the draped one (3D).
    - F = Ds·Dm⁻¹, where Dm is the 2×2 rest edge matrix and Ds the 3×2 draped one.
    - The principal stretches are the square roots of the eigenvalues of FᵀF. The map shows the largest as strain in percent.
    - Stretch along and across the grain is |F·g| and |F·g⊥|, where g is the grainline direction. So "tight across the back" and "dragging down the front" can be told apart.
    - Compression (a principal stretch below 1) shows where fabric bunches.
  - **Ease.** The distance from each vertex to the body surface, signed by the body's outward normals. Negative means the cloth sits inside the body: a bad drape rather than a tight fit.
  - `drape.py` gains `--result`. After the last frame it writes `NAME.result.json` next to the scene: each copy's final vertex positions in the order of `NAME.pieces.obj`, plus the format, version and a hash of the scene file.
  - The core (`Sloper.Core.DrapeFit`) reads it, checks the hash and the vertex counts, and computes both maps. A result whose hash does not match the current export is refused, never shown on the wrong mesh.
  - The script also stores the maps on the cloth objects as colour attributes named `Stretch` and `Ease`, to view in Blender.
  - The drape app shows a summary for each copy in a **Fit** tab: the area-weighted 95th percentile and the largest stretch, the smallest ease, and where each happens, by nearest seam or edge.
  - The design app gains **View → Fit Map**. It lays the latest result over the pieces in their drafted positions, so a sewist sees where to add or take out ease and changes the formula there.
  - The overlay only reads the file, so the design app does not depend on the drape app.
- **Layers, freeze and strengthen** (#202). Three placement options for a copy:
  - `layer`: an integer, 0 innermost. It adds `layer × layer_gap` (default 5 mm) to the clearance, so a jacket starts outside its shirt and the two do not begin intersecting.
  - `frozen`: the copy keeps its starting shape. A source whose copies are all frozen is exported as a collision object with no cloth modifier, which is quicker. For example, drape a shirt once, freeze it, and drape a jacket over it.
  - `strengthen`: a stiffness factor, default 1, for a piece with interfacing or a stiff collar. Blender has one maximum stiffness per cloth object, so the maximum becomes the highest fabric stiffness times its factor. Each vertex's weight in the stiffness group is scaled down from that.
  - The same options are in the drape app's Properties tab and in the drape server's `set_placement`.
- **Re-draping from the last result** (#202). After a variable or measurement change, the drape can start from the previous result instead of from the placements.
  - `opensloper-cli drape DRAPE --from-result`, and **Drape Again from Result** in the drape app.
  - Each new vertex is mapped onto the old result. Its rest position is found in the old flat mesh of the same piece and copy. Its starting position is the matching point (by barycentric coordinates) on the old draped triangle.
  - A vertex outside the old piece, where the piece has grown, uses the nearest old triangle.
  - The rest shape is still the new flat piece.
  - Sewn pairs may now be slightly apart, so a short sewing phase closes them (`--sewing-frames`, default 10 here).
  - It falls back to placements when copies are added or removed, a seam's pairing changes, or the result's hash does not match the previous export.
  - It works with **Re-draping in place** and the Blender add-on with a live link.
- **Curve tolerance in the mesher** (#202). Outline resampling also adds points where the chord leaves the curve by more than `tolerance` (default 0.5 mm).
  - A tight sleeve cap or neckline keeps its shape at 10 mm spacing without making the whole mesh finer.
  - At 10 mm spacing, a chord leaves a circle of radius 50 mm by about 0.25 mm, so this only adds points on tight curves.
  - On a seam, the finer spacing is used on both sides at the same fractions of length, so pairing stays even.
  - The interior grid does not change.

**To try on real hardware**

- A print with the Leather output profile.
- Alt-click to cycle coincident lines on a real desktop, as some window managers take it.
- DXF-AAMA on a real cutting system, checking the layers and file-level text.
- Machine SVG and DXF on a real cutter, and whether labels need a single-stroke font.

## Open questions

- Should buttonholes become a marking role?
- Should an output profile send roles to separate files or passes, one per laser operation?
- What values does each leather marking need (skive width and depth)?
- Leather hides: is there evidence the community needs them?
- Should seams join pieces of different patterns?
- Should the drape mesh spacing be set per material?
- Do game artists want the cloth mesh as even 10 mm triangles, or a coarser mesh that is easier to retopologise?
- Should fold markings become creases (stiffer bending along the line), and stitch markings a vertex group for topstitching detail in Blender?
- Is the generated body good enough to try the drape app on game characters, or does the user's own body (see To do) have to come first?
- Does Blender's rest shape key cover bending angles as well as spring lengths? If not, a wrapped piece will try to stay curved, so either the bend has to be small or the bending rest state set another way. Test before building zones.
- Which body levels should `level` offer by name (bust, waist, high hip, hip, knee, elbow)? Should they read the catalogue's height measurements or the body's own rings?
- What strain counts as too tight? Woven cotton and jersey differ a lot, so a fabric may need its own `stretch_limit` before the Fit tab can warn instead of only showing numbers.
- Should Fit Map live in the design app, or should the drape app have its own flat view of the pieces? The design app is where the fix is made, but it then reads a drape file.
- Is 5 mm a good default `layer_gap` for a shirt and jacket, or should it come from fabric thickness?

## Future ideas

Outside the roadmap; each is taken up only when the core is solid or the community asks.

| Idea | Notes |
| --- | --- |
| Notions library | More features for the Features tab: hooks and eyes, snaps, eyelets, elastic and pockets, and a notions list for the information block |
| Multi-size output | Nested sizes on one sheet for published patterns, evaluating the pattern once per size, with a screen-only overlay for checking grading |
| Scaled body figure | The measurements app's figure scaled to the entered values, so unusual proportions and typos stand out |
| ISO 8559-1 check | Check catalogue definitions against the standard and add clause references |
| Spread tool | The chain of rotations for slash and spread in one step |
| Fabric textures | Photos of the actual fabric for fills and in Blender; nap direction for layouts |
| Leather hides | A hide's outline traced from a photo, with flaws to avoid: a sheet whose free space for nesting is its outline less its flaws |
| Materials app | An app like the measurements app keeping a list of materials and their specifications for the design and publish apps |
| Assembly instructions | An exploded arrangement of the pieces (the drape app's placements are a starting point), a list of sewing steps, and printed instructions in the manner of flat-pack furniture: a parts list, an overview and numbered line-art steps. The full plan is in commit `183e011`'s `documents/design-3d-preview-in-blender.md` |
| A feature as one object | A feature kept editable, with its settings, once the first features show which settings people change |
| Buttons at the bust | Buttonholes spaced from a fixed point, one on the bust line and the others from it, when someone asks |
| Blender add-on with a live link | A panel in Blender lists a drape's patterns, their variables and sizes. It talks to the drape app or `opensloper-cli serve` through the Automation API, with its usual token. Changing a variable calls `set_formula`, re-exports and re-drapes in the open scene. It is an add-on the user installs in their own Blender, separate from the fixed script, so the API still cannot run Blender. No other garment tool has a live parametric link |
| Base patterns for artists | A small set of blocks (tee, trousers, hoodie, skirt, jacket) with drapes ready to place, in `docs/examples/`. Game artists rarely draft from scratch: Marvelous Designer's template garments are what they start from now |
| More facings | An all-in-one neck and armhole facing (two runs, one piece) and understitching lines, when people ask for them. |
| Other generated bodies | Optional bodies with a realistic shape and a skeleton, from MakeHuman's CC0 base mesh or the Anny parametric body (Apache 2.0), beside the lofted body, which stays the default as it needs nothing extra. The body's shape settings are fitted to a measurement set by measuring girths as for the user's own body and changing the settings until they match. Zones then come from the skeleton instead of the rings. The model files are data, downloaded on request, not linked code. Animated bodies, so a drape can follow a walk, would come after this |
| Web drape viewer | A page showing a drape result and its fit maps from an uploaded file, with no editing. The draped garment in 3D, and stretch and ease on the pieces. A designer can share a drape with a sewist who has no Blender. Only after fit maps (#202) are built (#204) |
