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
8. **Import and Export** of Seamly2D and Valentina files.
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
- Should the draped result be shown back in the drape app, and should seams join pieces of different patterns?
- Should the drape mesh spacing be set per material?
- Do game artists want the cloth mesh as even 10 mm triangles, or a coarser mesh that is easier to retopologise?
- Should fold markings become creases (stiffer bending along the line), and stitch markings a vertex group for topstitching detail in Blender?
- Is the generated body good enough to try the drape app on game characters, or does the user's own body (see To do) have to come first?

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
