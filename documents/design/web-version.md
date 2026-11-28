# Web version

Part of the [OpenSloper design](../opensloper-design-document.md). A web version runs in the browser with the same Pascal engine as the desktop apps, compiled to WebAssembly, under a new TypeScript editor. A Django server will handle accounts and subscriptions. The site never holds users' files. The Design, Publish and Measurements apps are built, as a beta.

**Why it is possible.** The core has no LCL dependency, and the Automation API already exposes every document operation as JSON-RPC. So the web needs a new UI, not a new engine. Name rules, formula checks and undo are the same code everywhere.

| Part | Runs in | Language | Does |
| --- | --- | --- | --- |
| Engine | Browser (Web Worker) | Pascal, compiled to Wasm | Core, document and API layers: evaluation, undo, pieces, exports |
| Editor | Browser | TypeScript | Canvas, tools, panels; talks to the engine through the API |
| Server | Server | Python, Django | The editor's files, accounts, subscriptions, simple pages |

The editor runs in the browser, since sending every drag to the server would make dragging lag. The server never takes part in drafting.

**No user data on the site.** Patterns and measurement files stay on the user's machine. Body measurements are personal data under PDPA, and stored files cost hosting. So the server keeps only what an account and a subscription need: a login and an email address. Payment goes through a provider, so no card data is held. Everything the engine does (evaluation, checks, exports) happens in the browser.

**The drape app stays desktop-only**, as Machine DXF does.

- The browser cannot run Blender. A web drape would mean downloading the export, running Blender locally and uploading the result.
- Drape users need Blender installed, so they have the desktop app. The web beta is for sewists who want nothing to install.
- A 3D view and placement editor would be a large piece of TypeScript.
- Simulating cloth in the browser would break the rule that the apps have no cloth solver.
- A viewer for a drape's result is a future idea (see [Open items](open-items.md)).

## Engine

- **Compiler:** FPC's `wasm32-wasip1` target. It exists only in the development compiler (trunk 3.3.1), so the web build uses a self-built cross-compiler while the desktop stays on the stable one. The core must compile with both, which `opensloper-make.sh test` will check. pas2js was rejected: it has no pointers, which Clipper2 uses.
- **One entry point**, `handle(request) → response`. It takes and returns a JSON-RPC message as text, the same as `opensloper-cli serve`.
- **Editor methods.** Methods only a canvas needs are named `editor_`. They have their own table (`EditorMethods`) in `Sloper.API.EditorServer`, whose `TEditorApiServer` answers them on top of the Automation API. The engine and `opensloper-cli serve` both use it. The editor methods are not MCP tools: a mouse position means nothing to Claude, and its tool list stays short. Methods useful to both editors and automation, such as `open` with contents, go in the Automation API itself.
- **In the module:** `src/core`, `src/document`, `src/editor`, `src/api` and the PDF, SVG and DXF writers. There is no LCL and no BGRABitmap, so `render` gives SVG only. PNG must be reached through something the module can leave out.
- **Runs in a Web Worker**, so a slow evaluation never freezes the page.
  A worker reply or request failure includes the request ID. A worker-level
  error rejects every waiting call, and subsequent calls fail immediately.

### Shared editing logic

Editing logic is in `src/editor` (`Sloper.Editor.*`), a layer without the LCL between the document and the apps. It is not rewritten in TypeScript, and not put in `src/core`, which stays the pattern model. The order is core → document → editor → API and UI, and the check forbids the LCL in the editor layer as in core.

As much as possible goes there:

- The units of `src/ui` that already did without the LCL have moved: Scene, Snap, View, RulerTicks, Completion, ObjectList, Suggestion, SuggestionGrade, SelectionEdits, PanelEdits, PropertyText and Garment.
- The canvas tools' table (Tools: names, captions, hints, icons and keys) has left `Sloper.UI.CanvasTools`.
- The logic still inside LCL units follows as the web editor needs it: the canvas tools' drags, and the properties panel's piece and note sections.
- The properties panel's rows and edits are in `Sloper.Editor.PropertyRows`. It says which rows an object shows and in what order (`PropertyRows`, by section and place as the desktop's sections build them), the choices' items, the undo names, and the edits as steps on the document. The desktop's sections still build their own controls, so a row added to one is added to `PropertyRows` too.
- What a tool's click makes is `Sloper.Editor.ToolEdits`, which the desktop's tools and the editor methods both call: a point, a line or curve with its points, a curve carried on, a circle, a rectangle, a piece, a notch added or removed, a seam's sides picked and the seam made, a note, a callout, a callout's tip moved. The web editor keeps only a two-click tool's first click, and draws the preview.
- The edge roles' captions (`RoleCaption`) are in `Sloper.Editor.PropertyText`.

Layout helpers for desktop widgets (CanvasInput, GridColumns, SideTabsLayout) stay in `src/ui`.

**Label placement is copied**, as `web/src/editor/labelPlacement.ts`. It is screen arithmetic on every frame with the browser's text sizes, so the TypeScript places the labels with a copy of `Sloper.Core.LabelPlacement`, tested with its cases. View and RulerTicks are also pixel arithmetic run on every frame, so the TypeScript mirrors them rather than calling the worker, and tests compare the two.

### Behind the API

What needs the evaluated pattern goes behind the API: snapping, completion, the object lists, formula suggestions and selection edits. Where a method shares a step with the desktop, both call the same `src/editor` code, named in the table. A refused edit is an answer with its reason, not an error. A selection that only shows things (`editor_objects_at`, `editor_handles`, `editor_label_keys`, `editor_bounds`, `editor_garment_marks`) leaves out objects gone since, as an undo can take them while the canvas still holds them; an edit to the selection refuses them.

**Drawing and finding things**

| Method | Gives |
| --- | --- |
| `editor_scene` | Everything to draw, in drawing order: the pattern's unit (which the rulers and grid count in); pieces with their grainline, fold, marking and notch strokes, label and chevrons; edges; seams with their sides; notes ready to draw; markers and points. Each with its state, lock, dimming and copies, and the slots of edges lying on others. A note comes with its lines (fields filled in), size, line height, font, box, frame and leader |
| `editor_tables` | Tools, commands with icons and menus, shortcuts, roles and point types |
| `editor_snap` | The snap for a place |
| `editor_objects_at` | The objects at a place. Given the selection, also the selected callout's tip and curve's handle there, which lie over everything |
| `editor_objects_in_box` | The objects in a box |
| `editor_bounds` | The box round objects, to reveal or zoom to a selection |
| `editor_handles` | The selected curves' handles: anchor, end, length field, and whether a formula or lock keeps it from a drag |
| `editor_label_keys` | Which objects to label (`LabelKeys`). What is labelled depends on what reads what, so it stays in the engine |
| `editor_note_preview` | One note as the scene draws it, with its text as typed. The canvas shows a note's text while it is typed in the Properties tab, without the whole scene |
| `editor_export_draft` | The draft as SVG, labelled as the canvas labels it, for Export SVG |
| `editor_print` | A PDF to print, in Base64, with the warnings the publish app would show. A layout is made in memory with the pattern and its set as text (`TLayout.LoadSourceText`), every piece placed as in a new layout, and written by the publish app's `LayoutToPDF` |

**Tools and the selection**

| Method | Does |
| --- | --- |
| `editor_tool_snap`, `editor_tool_click` | A tool's snap and click (`ToolEdits`) |
| `editor_seam_pick`, `editor_seam_make` | The Seam tool |
| `editor_delete` | The Delete key (`DeleteSelection`). Refused, with the reason, while another object uses one deleted |
| `editor_convert_point` | Tools > Points > Change To (`ConvertPointSelection`): the first selected point, placed from the rest. The type comes from the toolbar's *Change point to…* box, filled from `editor_tables`' `pointTypes` |
| `editor_copy`, `editor_cut`, `editor_paste` | Edit > Copy, Cut and Paste (`CopySelection`, `CutSelection`, `PasteFragmentText`), with the fragment's text in and out |
| `editor_drag_begin`, `editor_drag_to`, `editor_drag_end`, `editor_drag_cancel` | A drag: one undo step, worked out on every move, refusing other changes while it is open. It drags a point (free, or on one field, with the `guide` it keeps to), a note, a curve's handle (named by its length field) or a callout's tip. A tip snaps on each move and changes nothing until `editor_drag_end` hangs the callout from where it last snapped (`MoveCalloutTip`) |

**Panels**

| Method | Does |
| --- | --- |
| `editor_list_objects`, `editor_list_variables`, `editor_list_measurements` | The lists' rows. The measurements come with the tab's unsaved edits laid over the set (`TPendingMeasurements.Rows`), and the set's file, sizes, size used, test size, whether the set has any measurements (`hasMeasurements`, without which the test size is off) and count of edits |
| `editor_list_click` | The selection after a click, Ctrl+click or Shift+click on a list's row (`SelectionAfterClick`). Its keys are plain text (the `apTexts` kind), as a measurement's key is no object |
| `editor_complete` | Name completion. Caret and word are in characters, not UTF-8 bytes |
| `editor_variable_add`, `editor_variable_set`, `editor_variable_delete` | The Variables tab's edits (`AddVariableStep`, `CommitVariableCell`, `DeleteVariableStep` in PanelEdits) |
| `editor_variable_import` | The tab's Import…, from the other file's text and name (`ImportVariablesTextStep`), with the desktop's message and warning |
| `editor_measurement_add`, `editor_measurement_set` | The Measurements tab's edits. The editor server keeps them in a `TPendingMeasurements`, as the desktop's tab does, and drops them when another set is used |
| `editor_measurements_save`, `editor_measurements_revert` | Save makes the edits all at once (`TPendingMeasurements.Save`) and answers the set's new file, to download. With no set it makes one, named by the editor after the pattern, which the pattern records |
| `editor_measurement_size`, `editor_measurement_scale` | Another size of a size table, and the test size. Both are refused while edits wait |
| `editor_properties`, `editor_property_set` | The Properties tab, from `PropertyRows` (below) |
| `editor_suggest` | Formula suggestions, worked out afresh each call. With a size table, each suggestion's values at the first and last sizes, from a grade check the server keeps for the field. It keeps it until the pattern changes other than by a drag, as making it copies the pattern for each size |
| `editor_suggest_preview` | Where a suggestion would put the point, and its object at the first and last sizes, for the canvas while a suggestion is hovered |
| `editor_materials`, `editor_material`, `editor_material_set`, `editor_material_add`, `editor_material_delete` | The Materials tab's list and the Materials dialog's edits, by the material's place in the list (`MaterialList`, `PanelEdits`) |
| `editor_features`, `editor_feature_apply` | The Features tab's forms and Apply (`FeatureForms`) |
| `editor_problems` | The Problems tab: `PatternProblemList` in words, each with what it is about (an object or variable by ID, or a measurement by key), and the count of blocked objects |
| `editor_garment` | The Garment tab: the pieces as the canvas shows them, of one material or all, drawn as the desktop's SVG export draws them. With each piece's outline, the box round them, notes on what was left out and the materials to choose from. The server keeps a `TGarmentBuilder`, so only changed pieces are built again |
| `editor_garment_marks` | What a selection marks in the Garment tab: the selected pieces shown and the lines of selected seams (`Sloper.Editor.Garment`) |

**The document**

| Method | Does |
| --- | --- |
| `editor_changes` | What changed since it last answered (see the proxy, below) |
| `editor_snapshot`, `editor_save_complete`, `editor_mark_unsaved` | File writes and work in progress (see Files and storage) |

**The Properties tab's rows.** `editor_properties` gives an object's rows as data. Each has its id, kind, caption and value, whether it can be changed now, and a number's range. The kinds are text, name, formula, choice, check, button, problem, number, long text, font and colour.

`editor_property_set` edits a row through `PropertyRows`' steps, as the desktop's sections do. It covers:

- the name, or a formula as typed, and the Locked box;
- an edge's type and role, a marker, a repeat's ends and a seam's flip;
- a piece's cut, mirroring, fold, dart caps, grainline, material, fill and colour;
- edges' own allowances (emptying one goes back to the piece's) and mirrored ends;
- a note's text, size, printing, lines, box, font, bold, italic and leader, and making it free.

A run of changes to a number is one undo step, as the desktop's spin boxes merge. A grainline between two points is set with both at once (`from` and `to`), as the desktop waits for both. A refused formula says where the problem is.

**Speed.** A frame of a drag on the skirt pattern takes about 4 ms in Wasm under Node: the move, its evaluation, the changes and the whole scene (about 10 KB). So the editor redraws from a fresh scene on every move. Snapping works on the evaluated pattern the engine already keeps, so a mouse move is one query. A cached scene is added only if timing shows the need.

### Spike and size

**Spike results** (`web/engine/`):

- FPC trunk compiles the core, document, API, output and Clipper2 unchanged, with its own Wasm linker.
- Every regression case gives the same objects, values, states and SVG as the desktop, and layout exports are byte for byte the same.
- A formula edit with the bodice block's full evaluation takes 3.7 ms in Wasm, against 1.7 ms native.
- In headless Chromium the engine is ready in about 45 ms, and an edit takes 3 to 18 ms at the median. Evaluating on every drag in a worker is affordable.
- Two fixes were needed. `Sloper.Core.AppPaths` treats WASI as neither Windows nor Unix. FPC trunk's WASI `ExpandFileName` doubles a leading `/` (patched locally, to report to FPC).

**Engine size.** A build of the full engine is 4.62 MB, 610 KB with Brotli.

- Its code is 45% core, 37% RTL and FCL, 10% output, 5% API, 3% Clipper2 and 1% document.
- The largest library cost is Variants and its helpers (about 200 KB of code), which come with `fpjson`.
- The linker already leaves out whatever the entry point does not reach, as it does the drape units. So moving units between folders does not change the size.

**The core is not split.** A drafting-only engine could leave out the output units, the font and deflate code they use, and UnitConvert, Garment, Arrange and OutputProfiles. That is about 620 KB of 3.5 MB of code, some 80 KB after Brotli. It does not pay for a second module, a hand-over of the pattern between the two, and a wait at the first export. The offline editor downloads the module only on the first visit and after an update, which makes the saving smaller still.

**Stripping names.** `-Xs` leaves the name section in. Stripping it takes the engine to 4.14 MB, 540 KB with Brotli, with no change to the code. `opensloper-make.sh web --strip-names` does it. It is off by default while the engine changes, as the names make a stack trace readable, and is to become the release build's default once the engine is stable.

## Files and storage

**The engine takes files as text.** The browser has no ordinary filesystem, so the engine does not open files by path:

- `open` takes the pattern file's `text`, and `save` with `text` gives the contents back without writing (`TPatternDocument.LoadFromText`, `SaveToText`).
- `use_measurements` takes the measurement file's `text` (`UseMeasurementsText`).
- A pattern opened from text has no file name and no measurement set. The reply's `measurementsFile` is the reference the pattern stores; the editor resolves it against the pattern's folder and supplies the file.
- References between files stay relative paths with `/`, resolved by whoever supplies the file. So a set of files moves between desktop and web unchanged.
- A set given as text is never read or written on disk, so file watching skips it. `ChangeMeasurements` changes it in memory (`TPatternDocument.MeasurementText`), for the editor to save as a download. `set_measurement` refuses it, as its reply could not hand the file back.
- A layout's sources are read from files given as text (`TSourceFiles`), not disk, once the layout document has them (`TLayoutDocument.SourceFiles`, `OpenText`). They are kept by path, relative to the layout and with `/`, so undo, redo and reloading read them again.
- A pattern's measurement file is looked for beside it, as on disk. A source whose file is not given names its path (`MissingFile`), for the editor to find and give.

File watching is dropped on the web. File formats do not change.

**Opening and saving.** Files are opened and saved on the user's machine through the File System Access API where the browser has it (Chromium-based browsers; `FileAccess` in `ui/fileAccess.ts`). Elsewhere they are uploaded and downloaded. With the API:

- Open and Measurements… use the browser's pickers, which start beside the pattern.
- A pattern saves back to the file it came from (Save, Ctrl+S). Save as (Ctrl+Shift+S), or Save for a pattern from an example, asks for a file.
- Leave to write a file is asked while the user's click still counts, before the engine is.

**Finding the measurement file.** A pattern's measurement file is found from a folder the user grants once.

- When the pattern names a file that was not picked with it, the status bar offers Find it…. This asks for the folder, starting at the pattern's.
- The folder's handle is kept in IndexedDB. Later, the file is found by its path from the pattern as soon as the pattern opens (`resolve` gives the pattern's place in the folder).
- A folder the browser has stopped letting the page read is read again from the same button, as asking needs a click.
- A set chosen with Measurements… is recorded by its path from the pattern when a granted folder holds both, else by its name.
- The Measurements tab's Save writes to the set's file, found the same way, else chosen. The file is chosen before the edits are made, so cancelling keeps them waiting.

**Work in progress** is kept in browser storage, so a closed tab loses nothing. It never leaves the machine (`Autosave` in `ui/autosave.ts`).

- A second after each change, while the pattern is not saved, `editor_snapshot` gives the pattern file's text, without counting it saved, and the measurement set's text.
- When writing directly to a browser file, Save takes the same snapshot. After the write completes, `editor_save_complete` marks it saved only if the document still has that revision. A failed write leaves recovery in place.
- Both are written to the page's private file system (OPFS) under the tab's own id. A record in IndexedDB keeps when, the file name and the handles of the files they came from. Where the page cannot write OPFS files (some browsers allow it only in workers), the texts go in the record.
- Saving removes them.
- Each tab holds a Web Lock while it is open, so work whose lock is free was left by a tab that closed. On starting, the app offers the newest such work in the status bar, to open again or discard, then the next.
- Opened again, it is the pattern as it was, counted as not saved (`editor_mark_unsaved`), and saving goes to the file it came from.
- The Measurements tab's edits waiting in bold are not kept, as they live in the editor server, not the document.
- Open and Examples ask before replacing a pattern with changes not saved, which the tab's work in progress would otherwise lose.

## Editor

A TypeScript single-page app per job, as on the desktop, sharing one engine module. Each has its own page on the site: `/design/`, `/measurements/` and `/publish/`. Drafting comes first, opening measurement files the user supplies. The measurements editor follows on the same structure, then publish. There are no measurement forms on the server.

- The canvas draws from the computed geometry the engine reports (Canvas2D, WebGL if needed), not from `render`'s SVG.
- Tools, shortcuts, snapping, undo steps and colours match the desktop, following these design files.
- Output is written by the engine and downloaded. Printing goes through the browser's PDF viewer.
- Anything a subscription gates is checked when online, with a grace period offline.

**It works offline**, as an installable web app. A service worker caches the editor and the `.wasm` file, the only things it fetches, so it installs from the browser and runs without a connection.

- `sw.js` (`src/design/serviceWorker.ts`) keeps every file of the app in a cache named after the build: the page, its scripts, the engine, the icons and the guide's examples. It answers from the cache before the network.
- The bundler gives it the list of files and a version made from their contents. It starts from an empty `out/design`, so no file an older build left is kept.
- The first worker takes the page over at once. A new build's worker installs beside the running one and waits. An Update button at the toolbar's end reloads into it, first writing the work not saved to the browser, which the reloaded page offers back. The old build's cache goes once the new one takes over.
- `manifest.webmanifest` lets the browser install it, with the app's icon as SVG and as PNGs at 192 and 512 px (`resources/web`, from `make-icons.sh`).
- Registering the worker is a convenience, so a browser without service workers runs the app as before.

### The Design editor

The design app's page is built (`web/`, see its README). The TypeScript is one npm project in `web/`, with the spike's page.

**The canvas** is drawn with Canvas2D from `editor_scene`.

- Wheel zoom and middle-button pan.
- Rulers along the top and left, as on the desktop (`CanvasRulers` in `ui/ruler.ts`): ticks and numbers in the pattern's unit, the unit named in the corner, the pointer marked on both. They show at first, and the Rulers button or key hides and shows them, for the session until the web has preferences.
- A grid in the pattern's unit, at the desktop's default steps.
- Click and box selection.
- Point drags, through the drag methods.
- The Point, Line, Curve (Shift+click carries it on), Circle, Rectangle, Piece, Notch, Seam, Text and Callout tools, with the role box.
- Notes drawn and dragged. A note's text is typed in a field over the canvas, after Text or Callout or by double-clicking it.
- Labels: contextual, all or none, and all while N is held.
- Dependency arrows, as the desktop's: blue to what the hovered or selected objects read, and with the Dependents button on, purple to what reads them. `editor_label_keys` gives them with `links` (and `dependents`), from the shared `DependencyLinks`, since they follow the same selection and hover as the labels.
- Selected seams, and pieces' direction.
- Problem halos: a faint red halo under each object the Problems tab lists, as the desktop's, under the hover and selection paint. Always on; the web has no View → Problems yet.
- Notes are drawn in the browser's sans-serif, as the desktop canvas uses the system's font. Their boxes come from the engine, which in Wasm has no font files and estimates text widths, so a box may be a little wider or narrower than its text.

**Commands:**

- Delete or Backspace deletes the selection, as do the Objects tab and the Delete button, disabled while nothing is selected.
- Cut, Copy and Paste, by key and button. The fragment goes on the clipboard as text, so another tab or the desktop app (which takes a fragment from plain text) can paste it. The app keeps it too, for a browser that refuses the write. The paste key reads the clipboard from its paste event, the Paste button through the clipboard API, which the browser may ask about. In a text field they work on the text.
- Open takes the pattern and measurement file together, matched by the name the pattern records. Then Measurements…, Save (in place or a download, as Files and storage says), Save as, Undo, Redo and Fit.
- Examples opens the user guide's example patterns. They are copied from `docs/examples` into the site at build time and fetched with the measurement file each names beside it. They are our files, not users', so the site may hold them.
- Export SVG downloads the draft as the canvas shows it, as the desktop's Export Draft SVG.
- Print… (`PrintDialog`) asks for the paper: A4, A3 or Letter, starting at Letter where that is the usual paper. It makes the publish app's tiled print of a new layout of the pattern as it is open, unsaved edits included: the pages with their captions, overlaps and marks, and the cover with the test square, the reminder to print at 100% and the page map. Open to print shows it in the browser's PDF viewer, in a tab opened while the click counts (a blocked tab downloads it instead). Download PDF saves it. Placing pieces by hand, leaving pages out and other kinds of output are the publish app's. Printer calibration waits for preferences on the web, so it prints at exactly 100%.

**SVG stamps.** The toolbar reads the chosen SVG file locally and passes it as text to `editor_import_stamp`. The engine uses the desktop importer and the same one-step placement edit. It centres the stamp on the selection or in the canvas, stores the paths in the pattern and returns any import warnings. Files over the importer's size limit are refused before reading.

**The side panel's tabs** (`SideTabs`). A button above the tabs shows or hides the panel and reopens the last selected tab. The editor starts with the panel folded on narrow screens. A tab can sit at the foot of the column, and show a count on its icon.

- **Lists.** Objects, Variables and Measurements are lists on the shared `ListPanel`: search, rows by key, and the selection kept and painted by the list. A hidden tab builds its rows only once it shows.
- **Objects** follows the canvas selection, reveals what it selects, and zooms to it on a double-click.
- **Variables** is edited in the grid: name, formula and description. A formula has name completion from `editor_complete`, in a `FormulaCompleter` floating under the cell. A refused value stays in its cell in red, with the reason, as on the desktop. Add, Delete and Import… are below it. Import… reads another pattern file the user chooses and adds its variables, keeping those this pattern has. It selects the new ones and says what it kept, in a dialog too when one was kept or nothing came, as on the desktop.
- **Measurements** is edited in the grid, as on the desktop: values and descriptions, and a key only on a row Add made. Edits show in bold until Save makes them to the set and downloads its file, or Revert drops them. The size box and the test size pause while edits wait. Opening another pattern or set asks before dropping edits.
- **Properties** (`PropertiesPanel` in `ui/properties.ts`) comes first, as on the desktop. It draws the rows `editor_properties` gives for the selection as captions and controls. It builds them again only when the rows change, so a field being typed in keeps its text through a refresh, unless undo replaced the objects.
  - Names and formulas commit on Enter or leaving the field, with completion in formulas. Escape puts them back. A refused one keeps its text, with the reason under it in red.
  - Choices, boxes (with their caption beside them), numbers, colours and buttons commit at once. A colour is the material's, or its own from a colour box.
  - A note's text takes several lines: Enter adds one, and Ctrl+Enter or leaving commits. A font is typed, empty for the default. The note's text shows on the canvas as it is typed.
  - Choosing a grainline between two points enables the point boxes, and commits once both are chosen.
  - Giving an edge its own allowance puts the cursor in its new row.
  - A locked object's rows are read-only, apart from the Locked box.
- **Formula suggestions.** A formula row holding a value a formula could give (`suggest` on the row) has a wand at its right. The wand, or Alt+Down in the field, opens the suggestions under the row (`FormulaSuggestList` in `ui/formulaSuggest.ts`).
  - Each shows its value and how far off it is. With a size table it shows its values at the first and last sizes on a second line, and at every size in its tooltip. When none is close, a line above the nearest says so.
  - The field keeps the keyboard and passes the list Up, Down and Enter. Escape closes it. Taking one commits it as the field's formula.
  - While the list is open, dragging the point on the canvas changes only that field, along a dashed guide, and the list follows the drag.
  - Hovering or choosing a suggestion shows on the canvas where it would put the point and, with a size table, its object at the smallest and largest sizes.
  - With Contextual labels the canvas also labels the objects the rows in view read: `objects` on each of `editor_suggest`'s items, passed back to `editor_label_keys` as `suggestions`.
- **Materials** (`MaterialsPanel`) lists the materials and the cut list. `MaterialGrid` shows each material's swatch: a tint, or hatching at its angle. Edit or a double-click opens the Materials dialog (`MaterialsDialog`, a modal `<dialog>`).
  - New, Delete and each field are an undo step at once.
  - Typed fields commit on Enter or leaving them, and Escape puts them back. A refusal shows in red, with the reason.
  - Undo and Redo work inside the dialog, unless a field holds typing not committed. While it is open the window takes no other keys.
- **Features** (`FeaturesPanel` in `ui/featuresPanel.ts`) lists the features. It shows the chosen one's form for the canvas's selection, as the engine gives it: what it goes along, its fields and what Apply adds. Each feature keeps its values while another is shown, until another pattern is opened. A choice, a box, or a field left after typing asks the engine for the values that follow.
- **Garment** (`GarmentPanel` in `ui/garmentPanel.ts`) shows the engine's SVG as it comes.
  - The SVG sits in a shadow root, so its gradients' and filters' names meet no others on the page.
  - It zooms and pans by changing the SVG's view box, with a `ViewTransform` as the canvas uses. It starts fitted and on the first material. The wheel zooms about the pointer, a drag pans, and a double-click fits again. Follow canvas takes the canvas's zoom and centre.
  - Over the drawing it marks the selection as the desktop does: selected pieces outlined in blue, selected seams in orange, at a fixed width in pixels. The piece under the pointer gets a light tint, and the canvas highlights it too (`showOutsideHover`).
  - A click selects the piece on the canvas. Pieces are found by transparent copies of their outlines over the drawing.
  - Export… downloads the SVG at true size, or a PNG of the width asked for. The browser draws the PNG from the SVG, so its shading is the SVG's gradients rather than the desktop PNG's.
  - Light and shading strength are the defaults until the web has preferences.
- **Problems** (`ProblemsPanel` in `ui/problemsPanel.ts`) is at the foot of the column, as in every desktop app. Its title and icon count the problems, and it follows every change while hidden, for the count.
  - As `Sloper.UI.ProblemsPanel`, it knows nothing of documents and is shared by every app's page. Each app fills it with problems keyed by what they are about, and is told which key is chosen, pointed at or double-clicked. Those that stop printing are red.
  - The design page fills it from `editor_problems`, keying each by its object, variable or measurement.
  - The side panel's and the Problems tab's styles are in `ui/sidePanel.css`, which each page links.
  - Choosing a problem, by a click or Up and Down, selects its object on the canvas and brings it into view.
  - For a variable or measurement it opens that tab at its row (`chooseKeys`, which scrolls the row into view once it is listed).
  - Pointing at a problem highlights its object on the canvas. A double-click zooms to it.

**Talking to the engine.** Tools, shortcuts, and edge role colours and dashes come from `editor_tables`. `PatternDocument` asks `editor_changes` after every call, and reloads the scene when the pattern changed. Mouse moves go through a latest-only queue, so a slow answer never piles up requests.

**The browser test** drives the built app in headless Chromium. It:

- opens the skirt, chooses from the lists and searches them;
- adds a variable, names it, has a formula refused and then taken, opens the completion list and deletes the variable;
- has a measurement's value refused and then taken, saves the set and reads the downloaded file, adds and reverts a measurement, and tries a test size;
- adds a point, drags it and undoes;
- draws a line, a curve whose handle it drags, a rectangle made a piece with a notch, a circle and a seam;
- writes a note and a callout, and moves the note and the callout's tip;
- labels everything;
- edits in the Properties tab the added point (renamed, a formula refused and put back, another taken, a marker chosen, locked and unlocked), the new piece (cut twice, folded, given its own colour) and the note (its text retyped on two lines, made bold);
- selects a piece in the Garment tab and exports it, and chooses a problem in the Problems tab;
- checks that every listed example is on the site, and opens one.

### Structure

**Plain TypeScript, no UI library**, with the structure of the desktop UI copied. Each `src/ui` unit the web needs becomes a module of the same name (`Sloper.UI.ListPanel` → `ui/listPanel.ts`), with the same classes and hierarchy:

- a list panel base, with the objects, variables and measurements panels;
- property sections for the properties panel;
- tool handlers, with the snap tool under the point, edge and shape tools;
- a canvas host.

A fix or feature then lands in the same place in both. Names follow TypeScript's conventions (no `T` prefix, camelCase members) but are otherwise unchanged. The differences are kept where the platforms differ:

- **The document is a proxy.** `PatternDocument` in TypeScript sends JSON-RPC to the worker. It gets back the same change set as the desktop (`pattern`, `objectsReplaced`, `measurements`, `history`, `file`, `view`), and passes it to listeners as the desktop's `AddListener` does. The engine's editor server listens to its document and gathers the changes. `editor_changes` gives what gathered since it last answered, with the undo and redo names and the modified flag. The worker asks after each call, so every answer is followed by its changes without the API's replies changing shape. Every call is asynchronous; during a drag only the latest request counts, and older answers are dropped.
- **Widgets are ours.** A small control base wraps a DOM element, standing in for the LCL's `TCustomControl` and `TPanel`. The list grid is our own, on a table. Nothing from npm is in the shipped editor.
- **No `Free`, but listeners are removed** when a panel goes, through a `dispose` method, so a closed panel is never kept alive by the document.
- **Shared tables come from the engine**, not copied. Shortcuts, commands and their captions are read from it as JSON, so the two editors cannot drift. User-visible text sits in one strings module, as `resourcestring` does on the desktop.

### The Publish editor

The Publish app's page is at `/publish/` (`src/publish/`, as `Sloper.Publish.MainForm`), built in small steps (#85), and a beta like the Design app.

- **Open** takes a layout with its patterns and measurement files, or patterns alone, which start a layout as the desktop's Open does.
- `LayoutDocument` (`document/layoutDocument.ts`) is the open layout, as the desktop's `TLayoutDocument`.
- The engine says which files the sources still need, by their paths from the layout. The chosen files have names only, so each is matched by name and given. A pattern found may name a measurement file, which is looked for in turn.
- The title names the layout. The status bar has a message and the problems' count, as on the desktop, with how many stop printing. After each change the message sums up the pages, blank and left out, or the one sheet's size, or the material used (`PreviewSummary`), unless a command says what it did.
- **The preview** (`PreviewCanvas` in `ui/previewCanvas.ts`, as `Sloper.Publish.PreviewCanvas`) is drawn with Canvas2D from `publish_scene`: the cover, the pages (blank ones grey, left-out ones crossed), the pieces with their tint, seam line, marks, lines and label, and the information block's boxes, with its text once it is large enough to read.
- Fit Pages, Zoom In, Zoom Out and Zoom Area are on the toolbar. The wheel zooms about the pointer, and the middle button or Space with a drag pans. A new layout is fitted.
  - Zoom Area zooms to a box dragged, in on a click, out on a Shift+click; pieces cannot be pressed while it is on. Escape or its key turns it off.
- **Keys** come from the engine's tables (`publish_tables`, the desktop's `saPublish` shortcuts), as the design page's do:
  - The toolbar's commands (Open, Save, Save As, Export PDF, Undo, Redo, the zooms and Zoom Area) click their button, so a disabled one does nothing. Each button's hint names its keys, with Mod as Ctrl, or Cmd on macOS (`shortcutText`).
  - A field being typed in keeps its own Undo, Redo and letters.
  - Away from fields, as the desktop's preview takes them: Delete or Backspace sends the selected piece back to the tray or deletes the selected note; Escape lets go of a drag, a box, Zoom Area or the selection, the first there is.
  - Print waits for step 11; Reload has nothing to read again on the web.
- A press selects the piece under it, outlined in blue, as `publish_press` finds it. Dragging moves it, one undo step:
  - The engine moves it (`publish_drag`), on the desktop's 0.5 mm grid, and the scene is read again after each move. Only the newest move waits to be sent.
  - Letting go ends the step (`publish_release`). A drag the browser takes away puts the piece back (`publish_cancel`).
  - The press, the drag and the drop are `TPreviewDrag` (`Sloper.Output.Preview`), which the desktop's preview uses too.
- Sheet notes are drawn over the pieces, each in a dotted frame, as the desktop's `DrawNotes`: the leader, the white box, then the drawing or the text in its size and font, a tint when too small to read. The pattern notes printing with the pieces are drawn too, without a frame. The engine gives each in the design editor's scene shape (`SceneNote`).
  - A press on a note chooses it, outlined in blue, and opens the Notes tab. It lies over pieces, so it is found first. Dragging moves it, one undo step, as a piece.
- **The toolbar** has the desktop's commands in its order: Open, Save, Undo, Redo, Zoom In, Zoom Out, Fit Pages, Zoom Area, then Print…, Export PDF, SVG and DXF.
  - Where the browser has File System Access, Open uses its picker, and Save writes the layout back to the file it came from; Save As, shown only there, writes another. A new layout's first Save asks where. Only the text written counts as saved (`publish_text`, then `publish_saved`), so a failed write or a change made meanwhile keeps the layout marked.
  - The files the sources still need are looked for by their paths from the layout, or from the pattern a new layout was started for, in a folder the user has granted (`FileAccess.findBeside`), round after round, as a pattern found may name a measurement file. A folder the page may not read yet needs a click on Find them…, which asks for it. A layout started before its pattern's files were found is started again with them, so every piece is placed, as on the desktop.
  - Elsewhere Save downloads the layout file and counts it saved, and Open uploads.
  - The title marks a layout not saved, and leaving or opening another asks first.
  - Work not saved is kept in the browser as the design page's is (`Autosave`): the layout's text and every file its sources were given (`publish_snapshot`), with the files it came from, so it still saves to them. Another tab offers it once the tab that kept it has closed; opened again it counts as not saved (`publish_mark_unsaved`). Each app's work is its own, as both share the site.
- **Offline**: the page has a service worker and manifest of its own, as the design page has (`ui/serviceWorker.ts`, `ui/offline.ts`), with its own cache, and an Update button when a new build is ready.
  - Not yet as the desktop: a pattern or measurement file added in the Patterns tab is recorded by its name, beside the layout, where the desktop records its path from the layout; Save As into another folder keeps the paths the sources had.
  - Undo names the step it would take, as the desktop's menu does.
  - Print… (`publish/printDialog.ts`, as `Sloper.Publish.PrintDialog`) opens the PDF Export PDF writes in the browser's viewer, in a tab opened while the click counts, or downloads it, as the design page's Print… does (`deliverPdf`). The browser's print dialog chooses the printer, copies and pages, so this one says which to print first: the cover with the test square, then the rest. It is refused while a problem stops printing.
  - Printer calibration waits for preferences on the web, so it prints at exactly 100%.
  - Exports are downloads, refused while a problem stops printing.
  - Machine DXF, for cutting machines, is the desktop's only, with the machine profiles it needs. The web stops at PDF, SVG and DXF-AAMA.
- **The side panel** (`SideTabs`) has the desktop's tabs in its order. The Patterns tab (`publish/patternsTab.ts`) comes first:
  - The patterns in the layout, each captioned with its size once one is chosen, in red when it cannot be read.
  - Add pattern… and Remove pattern. Choosing a pattern adds it with its copies in the tray, one undo step each, and says how many.
  - For the pattern chosen: its measurement file, Choose measurements…, Use the pattern's own, and its size.
  - Files come from the browser's file picker and are given to the engine by name, as Open gives them. A pattern added may name a measurement file the layout lacks; one chosen with it is found by name, else the engine says it is missing.
  - The edits are `TLayoutDocument`'s (`AddPattern`, `RemovePattern`, `SetMeasurements`, `SetSize`), which the desktop calls too.
- The Materials tab (`publish/materialsTab.ts`), as the desktop's: a row for each material the patterns need, with its size, pieces and how much, then each material's notes and how the estimate is made. It only reads (`LayoutMaterialNeeds`).
- The Info tab (`publish/infoTab.ts`), as the desktop's Information Block tab: Show, the fields it shows, On every page and the corner.
  - The fields are greyed while the block is hidden; the corner and every page while the output is not tiled (`OutputSettingUsed`).
  - A field shown anew prints last (`TitleFieldsWith`). Each change is `TLayoutDocument.ChangeTitle`, one undo step, which the desktop calls too.
- The Notes tab (`publish/notesTab.ts`), as the desktop's:
  - Add note puts one at the left below the pieces, chosen, its text ready to type over.
  - The chosen note's text with fields, size, lines, white box, font, bold and italic, and Delete note.
  - Typing sends the newest text once the one before is answered. Changes to one note within a second join one undo step.
  - A font name the engine cannot use (`CheckFontName`) is refused, said in the status bar and put back.
  - The edits are `TLayoutDocument`'s (`AddNote`, `ChangeNote`, `DeleteNote`), which the desktop calls too.
- Then the Pieces tab (`publish/piecesTab.ts`), as the desktop's:
  - Selected Piece: Turn 90°, Flip and Back to tray, for the piece selected on the pages.
  - Arrange: Place new pieces and Pack pieces. Pack fits the view and says what it did in the status bar.
  - Tray: the copies waiting to be placed. One dragged onto the pages is placed centred where it is let go, kept on the sheet (`publish_drop_copy`). A double-click or Enter places one in the rows below the others. Either way it is selected. A copy whose piece has a problem in the pattern is greyed and cannot be placed.
  - The edits are `TLayoutDocument`'s (`TurnPiece`, `FlipPiece`, `UnplacePiece`, `PlaceCopy`), which the desktop calls too, so both name the undo steps alike.
- The Output tab (`publish/outputTab.ts`), last above Problems, as on the desktop:
  - Output: tiled pages, large format, projector or material sheet, with the roll's or material's sizes and quarter turns.
  - Paper: A4, A3, Letter or a custom size, the margin, the overlap and the alignment marks.
  - Content: the piece fill, the output profile and the material the layout is limited to.
  - Export: PDF, SVG and DXF, as on the toolbar. Print joins them once the web can print.
  - Settings that do not apply to the kind of output are greyed (`OutputSettingUsed`). A number is sent once typed or stepped.
  - Each change is `TLayoutDocument.ChangeOutput`, as the desktop's: changes within a second join one undo step; pages left out are forgotten once the page grid moves; a new material or kind takes its material's size. A change leaving nothing to print on is refused, said in the status bar and put back.
  - The machine profile is left out: it is only for Machine DXF, which the web does not offer.
- A right-click on a page leaves it out of the print, or puts it back (`TLayoutDocument.TogglePage`), whatever is on it.
- The side panel has the Problems tab at its foot, filled from `publish_state`'s problems, the blocking ones red. Clicking the status bar's count opens it. Choosing a problem about a placement selects that piece, as on the desktop.
- The view is `ViewTransform` (`editor/view.ts`), as the design canvas's. The desktop's preview has its own copy (`TPreviewView`), which zooms in only to 20 px per mm.

**Its methods** are named `publish_`, in their own table (`PublishMethods` in `Sloper.API.PublishServer`). The editor server passes them to a `TPublishApiServer`, which holds the layout document, so both pages use one engine module. They are not MCP tools.

| Method | Does |
| --- | --- |
| `publish_tables` | The Publish app's shortcuts, as `editor_tables` gives the design app's |
| `publish_open` | Opens a layout from its text, or starts one for a pattern among the files, with the files given (`OpenText`, `NewForPattern`) |
| `publish_add_files` | Gives more files, and reads the sources again. Not an undo step |
| `publish_state` | `layout_state`'s answer, with `missing`: the files the sources need and were not given; `tray`: the copies waiting, each with its caption and whether it can be placed; and `summary`, the status bar's |
| `publish_patterns` | The Patterns tab's list: each pattern's source id, caption, measurement file, whether the layout chose it, its size and sizes, and its problem |
| `publish_add_pattern` | Adds a pattern by its path, with files for it to read; one undo step |
| `publish_remove_pattern`, `publish_set_size` | Removes a pattern, or reads it at another size, by its source id; one undo step |
| `publish_set_measurements` | Reads a pattern with another measurement file, given with it, or its own for an empty path; one undo step |
| `publish_add_note`, `publish_delete_note` | Adds a sheet note below the pieces, or deletes one by its index; one undo step |
| `publish_note` | A sheet note as typed, for the Notes tab |
| `publish_set_note` | Changes a sheet note's text, size, lines, box, font, bold or italic; refuses a font name that cannot be used |
| `publish_materials` | What each material the patterns need, as the Materials tab lists it |
| `publish_title` | The information block: whether it shows, its fields, every field there is, its corner, every page, and whether the corner and every page apply |
| `publish_set_title` | Shows or hides it or one field, or changes its corner or every page; one undo step |
| `publish_output` | The Output tab's settings, which apply (`used`), and the papers, materials and output profiles to choose from |
| `publish_set_output` | Changes them, as the desktop's tab does (`ChangeOutput`); refused when nothing is left to print on |
| `publish_toggle_page` | Leaves the page at a point out of the print, or puts it back; one undo step |
| `publish_scene` | What the preview draws, worked out as the desktop's preview does (`PlacedPieces`, `Pages`, `PreviewCover`, `PreviewTitleBoxes`), with the sheet notes and the pattern notes printing with pieces |
| `publish_press` | Holds the sheet note at a point, or else the smallest placed piece (`ShapeAt`), for a drag; changes nothing |
| `publish_drag` | Moves what the press holds; the first move opens one undo step |
| `publish_release`, `publish_cancel` | Ends the drag's step, or puts back what it moved |
| `publish_drop_copy` | Places one copy from the tray centred on a point (`PlaceCopyAt`), one undo step |
| `publish_undo`, `publish_redo`, `publish_place_pieces`, `publish_pack` | The layout methods of the same names (`Sloper.API.LayoutServer`), each one undo step |
| `publish_turn`, `publish_flip`, `publish_unplace` | Turn 90°, Flip and Back to tray for a placed piece, by its placement index; each one undo step |
| `publish_place_copy` | Places one copy from the tray, by its index there, in the rows below the others; refused when its piece cannot be placed |
| `publish_save` | The layout file's text, counted as saved (`TLayoutDocument.SaveText`), to download |
| `publish_snapshot`, `publish_mark_unsaved` | The layout's text and the files its sources were given, kept as work in progress; and counting work opened again as not saved |
| `publish_text`, `publish_saved` | The layout file's text, to write to a file, and then that it was written (`TLayoutDocument.MarkSaved`): only that text counts as saved |
| `publish_export` | The layout as PDF, SVG or DXF-AAMA, in Base64, refused as the desktop's export is (`LayoutBytes`) |

The replies of the first three are `publish_state`'s, which also gives the undo state and whether the layout is modified. `LayoutDocument` asks for it after every change and tells its listeners.

### The Measurements editor

The Measurements app's page is at `/measurements/` (`src/measurements/`, as `Sloper.Measurements.MainForm`), a beta linked from the site, as Design and Publish are (#84).

- **The toolbar** has Open, Save, Save As, Undo and Redo, with shortcuts from the engine. Open takes a measurement set or size table (`.slm`). A refused open keeps the set and says why. Changes not saved are dropped only when the user agrees.
- **Examples** follows Open, as in Design and Publish. It opens the user guide's measurement files: one person, the size table, and the skirt and bodice tutorials' sets.
  - `measurements/examples.ts` lists them. The bundler copies them from `docs/examples` into the app, so they work offline.
  - One opens as a file without a handle, so Save asks where to put it. Changes not saved are dropped only when the user agrees.
- **Import…** and **Export…** follow, as on the desktop (`measurements/seamlyDialogs.ts`). The engine reads and writes the files with the desktop's `Sloper.Core.SeamlyFormat`.
  - Import… takes a Seamly2D or Valentina file (`.smis`, `.smms`, `.vit`, `.vst`), read in the browser and given to the engine as text.
  - The file becomes a new set, named after it as `.slm`, not saved and with nothing to undo. Changes not saved are dropped only when the user agrees.
  - A dialog reports what was read, renamed to the catalogue's keys, kept, corrected and noted, as the desktop's report window.
  - A file that is not one, or does not read, is refused with the reason, and the set open stays.
  - Export… commits the cell being edited, then asks which kind, as the desktop's save dialog's filter: multi-size (`.smms`, `.vst`) for a size table, or individual (`.smis`, `.vit`) of the size whose column the chosen cell is in.
  - The file is downloaded, and the set does not change. A refusal, such as sizes Seamly2D cannot take, stays in the dialog, so another kind can be chosen.
  - What could not be carried over exactly is reported in the same dialog as Import's.
- **Check Against Pattern…** and **Stop Checking** follow on the toolbar; the desktop has Stop Checking in its File menu, which the page has none of.
  - Check Against Pattern takes a pattern (`.sloper`), read in the browser and given to the engine as text. A file that is not one, or does not read as one, is refused with the reason, and the check before stays.
  - **Pattern Check** shows under the table while checking (`PatternCheck` in `measurements/patternCheck.ts`). It says the pattern has everything it needs, or lists what the set cannot give it: a key it lacks, or a key with no value for some sizes.
  - Choosing one shows its details beside the table. **Add or go to it**, a double-click or Enter adds a key the set lacks, with the catalogue's description, or goes to the empty value at its first size.
  - The pattern is not read again when it changes, as the desktop's is, since the page has only the text it was given.
  - It stays while another set is opened, as on the desktop.
- **Saving** writes the set to its file in browsers with File System Access. Save As picks another file, and Save downloads where the browser has no file picker. The page refuses to overwrite a set that changed on disk since it was read or written.
- **Work in progress and offline use** use the same browser storage and service worker as Design and Publish. A closed tab's unsaved set can be recovered and saved to the file it came from.
- **The title** names the file, with the modified mark while it has changes. **The status bar** has a message.
- **Name and Notes** are above the table, as on the desktop.
  - Enter, or leaving the field, commits it, as the desktop's `EditingDone`. Each change is one undo step; unchanged text makes none.
  - Escape puts back the set's text.
  - A field with text not yet committed keeps it when the set changes, until another set is opened. Opening another set commits it first, so the user is asked before it is dropped.
  - They are off until a set is open.
- **The table** (`MeasurementGrid` in `measurements/measurementGrid.ts`) is the shared `ListPanel`, as the desktop's grid: the key, a value column a size, or one Value column for a set without sizes, and the description, at the desktop's widths. It chooses one row at a time and has no search.
  - Every cell is edited in the grid, as the Design page's lists are, each edit one undo step. A key is renamed, and the status bar says patterns using the old key will show it as missing. A value is a number in the unit shown, a comma taken as the point, or blank to clear it in a size table. A refused edit stays red with the reason. An unchanged cell is not committed, so going through a table in inches does not round it.
  - **Add**, **Delete**, **Up** and **Down** are over the table, on the left, as on the desktop. Add opens the new row's key to type. Delete, or the Delete key, asks first. A moved row stays chosen.
  - **The size buttons** follow them, as on the desktop: Add size…, Rename size…, Delete size, Size left and Size right.
    - All but Add size act on the size whose column the chosen cell is in, and are off elsewhere.
    - Add size and Rename size ask for the name. A name that is empty or in use is refused, with the reason in the status bar.
    - Add size puts the size at the end. In a set without sizes, the first size takes the values, so the set becomes a size table.
    - Delete size asks first. The last size cannot be deleted.
    - A size moved left or right takes its values, and the chosen cell goes with it.
  - `ListPanel` takes any document that reads (`ListDocument`). It follows a `PatternDocument`'s changes itself; the measurements page tells its table when to build the rows again. `setColumns` gives it a column a size. When a rename changes the chosen row's key, its owner hears of the new selection.
  - The current cell keeps its column when the columns change, while that column can still be edited. Its owner hears when it moves to another column (`columnChanged`).
  - The grid's styles are in `ui/listPanel.css`, which the design page links too.
- **Show in**, over the table at its end as on the desktop, chooses mm, cm or inches. The engine formats the values in it (`FormatMeasure`), so they read as the desktop shows them. It starts at mm and is not kept yet.
- **The side panel** is on the right, as on the desktop, beside Name and Notes, the bar and the table. The body figure fills it over **Add From the Catalogue**, which is at its foot (`CatalogueBrowser` in `measurements/catalogueBrowser.ts`).
  - A group, a search, and the catalogue's measurements the set does not have yet, as the desktop lists them.
  - Under the list, the details of the measurement chosen in it, else of the table's row: its name, description, how to take it, and its typical range in the unit shown.
  - **Add to the file**, a double-click or Enter adds the one chosen at the end, with its key and description. Its row is chosen at its value, ready to type, and the list's choice is cleared.
  - A value outside its typical range is kept, as on the desktop. The status bar says so and its cell is tinted, but not on the chosen row.
  - **The body figure** (`BodyFigure` in `measurements/bodyFigure.ts`) shows where the set's measurements are taken, on front, back and side outlines, as the desktop's.
    - The engine draws it as SVG at the panel's size (`Sloper.Output.BodyFigureSVG`), and the page shows it as an image. The outlines are the desktop's curve, BGRABitmap's crossing spline worked out in Pascal, so the Wasm needs no BGRABitmap.
    - The measurement whose details show is highlighted on it; the table's row under the pointer is highlighted over that.
    - The pointer on a measurement's line shows its details, and a click chooses its row at its value. The engine says which line a point is on (`measurements_figure_at`).
  - The page fetches `measurement-catalogue.json`, which the build copies beside it, and gives it to the engine. Without it the table still works, and the status bar says why.
- `MeasurementDocument` (`document/measurementDocument.ts`) is the proxy of the engine's set, as `LayoutDocument` is of the layout.

**Its methods** are named `measurements_`, in their own table (`MeasurementsMethods` in `Sloper.API.MeasurementsServer`). The editor server passes them to a `TMeasurementsApiServer`, which holds a `TMeasurementDocument` of its own, apart from the design page's pattern and measurements. They are not MCP tools.

| Method | Does |
| --- | --- |
| `measurements_open` | Opens a set from its `.slm` text (`TMeasurementDocument.OpenText`): no file to watch, nothing to undo, not modified. Text that cannot be read is refused, and the set open stays |
| `measurements_state` | The set open, as its `.slm` file holds it (`SnapshotText`), without counting it as saved; an empty set before one is opened |
| `measurements_set` | A cell as typed, by the measurement's `key` and the `column` (key, value with its `size`, or description), as the desktop window commits it (`RenameKey` trimmed, `SetValueText` in the unit, `SetDescription`). A refused edit answers `done` false with the `reason`; `key` is the measurement's afterwards |
| `measurements_add` | A measurement at the end with a free key (`AddMeasurement`), answering its `key` |
| `measurements_delete`, `measurements_move` | Deletes a measurement, or moves it to `index`, by its key |
| `measurements_set_name`, `measurements_set_notes` | The set's name or notes, as typed (`SetName`, `SetNotes`); no undo step when unchanged |
| `measurements_add_size` | A size at the end, by its `name` (`AddSize`). A set without sizes becomes a size table. A name empty or in use is refused with the reason |
| `measurements_rename_size` | The `size`, by its index, renamed to `name` (`RenameSize`), refused as Add size is |
| `measurements_delete_size` | The `size` and its values (`DeleteSize`); refused for the last size |
| `measurements_move_size` | The `size` moved to the column `index` (`MoveSize`), with its values |
| `measurements_catalogue` | Loads the catalogue from its text (`TCatalogue.LoadFromText`). One that cannot be read is refused, and the one loaded stays |
| `measurements_catalogue_list` | The catalogue's measurements the set lacks, by `group` and `search` (`TCatalogue.Search`), each with `key` and `name` |
| `measurements_catalogue_entry` | An entry's name, description, how to take it and typical range in the unit; `found` false when there is none |
| `measurements_add_known` | A catalogue measurement at the end, with its key and description (`AddKnown`). A key the set has, or one not in the catalogue, is refused |
| `measurements_figure` | The body figure as SVG, `width` by `height` pixels, with the set's measurements and the `highlight` |
| `measurements_figure_at` | The set's measurement whose line is within a few pixels of `x`, `y` on a figure of that size, else empty |
| `measurements_check_pattern` | Checks the set against a pattern from its `name` and `text` (`UsePatternText`, `PatternTextMeasurementKeys`). One that does not read is refused, and the check before stays |
| `measurements_stop_check` | Stops checking |
| `measurements_add_missing` | A key the pattern needs at the end, with the catalogue's description when it has one (`AddKnown`) |
| `measurements_import` | A Seamly2D or Valentina file in place of the set, from its `name` and `text` (`ImportSeamly`, `TakeImported`): new, not saved, nothing to undo. Answers the `report`: `count`, and the lines `translated`, `kept`, `corrected` and `notes`. A file that does not read is refused, and the set open stays |
| `measurements_export` | The set as a Seamly2D or Valentina file of the `kind` (smis, vit, smms or vst; `ExportSeamly`), with the `notes` on what could not be carried over. An individual file from a size table holds the `size` given by its index, else the selected one. Written from a copy, so the set does not change |
| `measurements_undo`, `measurements_redo` | The document's Undo and Redo; refused when there is nothing to take |

Every one takes `unit`, the table's: mm (the default), cm or in; a bad one is refused before the set changes. Every one answers with `set`, and with the table as the page shows it: `unit`, `sizes`, and `rows`, each with its `key`, `values` (one a size, or the one value, as text in the unit, empty where there is none), `outside` (for each value, whether it is outside its catalogue entry's typical range) and `description`; `measurements_set` adds the `warning` for such a value; `pattern`, the pattern checked against, and `missing`, each with its `key` and the `sizes` with no value; and with `modified`, `canUndo`, `canRedo` and `undo`, the step Undo would take. Each edit is one undo step of the document's own history. `measurements_export` answers only its `text` and `notes`.

## Server

Django serves the editor and `.wasm` file, accounts (with the admin as back office), subscriptions and simple pages as templates. It stores no patterns or measurements and runs no engine jobs. Its own packages are kept to what the job needs and locked, and nothing they use reaches the engine.

**What a subscription pays for.** The engine and editor are GPL and run in the browser, so anyone may host a copy. A subscription cannot sell the program, only what the site adds:

- our own library of blocks and patterns, drafted by us and licensed apart from the code (pattern files are data, not part of the program);
- use of the Claude assistant, whose API calls cost money per use. Calls pass through the server and are not kept. Measurements in a prompt are still processed, so the privacy notice says so;
- official builds and support.

The first web version is the editor alone; subscriptions come once it works.

**Licence.** The engine and editor sent to the browser are distributed, so GPLv3 applies and the source is offered. The Django server is not distributed, so GPLv3 would not require publishing it (the project does not use AGPL), and it does not link the engine. It is published anyway, in `site/` under GPLv3, so the project is one repository. A subscription sells what the site adds, none of which is in the repository:

- secrets and keys are in the server's environment;
- accounts and payments are in its database;
- the pattern library, licensed apart from the code, is in a store of its own.

To be checked with a lawyer before the service is sold.

**Built so far** (`site/`, issue #86):

- the home page, with the web Design app at `/design/` and Publish app at `/publish/` as a beta, free with no sign-up, and the desktop downloads beside it;
- no database yet;
- `manage.py import_opensloper`, which copies the built app and the site's pictures and version from the checkout;
- Django under gunicorn behind the ISPConfig server's Apache, which serves the app and the static files itself.
