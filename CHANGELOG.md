# Changelog

What changed in each version of OpenSloper. Changes are added under the
version being worked on, the `APP_VERSION` in
`src/core/sloper.core.version.pas`, and the release workflow puts that
version's section in the notes of its GitHub release. A version left without
notes here gets the list of its commits since the last release instead
(`opensloper-make.sh release`). Issue numbers (#3) link to GitHub.

The layout follows [Keep a Changelog](https://keepachangelog.com): Added,
Changed, Fixed and Removed under each version.


## 0.10.0

### Added

- Publish can create, rename and edit named output and machine profiles from
  the Edit menu (#57).
- Web Design shows a faint red halo around objects listed in Problems
  (#162).
- Web Design draws the dependency arrows: blue to what the hovered or
  selected object reads, and with Dependents on, purple to what reads it
  (#161).
- A point along an edge or between points has a *Measure by* row, to switch
  between a length and a ratio, and a point along an edge a *Measured from*
  choice of the edge's ends. It stays where it is; its formula becomes a plain
  number, which Undo brings back. `convert_point` takes `mode` and `end`
  (#158, #159).
- The user guide has a Development page: getting the code, building, testing,
  and links to the Pascal source documentation (#47).

### Fixed

- The Test Sizes slider in Design is disabled when there are no measurements
  to scale, in the desktop and web apps (#175).
- The Lines panel's Save As and Delete preset buttons share a width and use
  the standard spacing (#174).
- Shortcut hints in web Design show Ctrl or Cmd for the current platform
  (#160).

## 0.9.0

### Added

- The Publish app runs in the browser too, as a beta at
  opensloper.com/publish/, linked from the home page (#85). It opens a
  layout with its patterns and measurement files, or patterns to start one,
  on the same engine as the desktop app. Pieces and notes are dragged,
  turned, flipped, placed from the tray and packed, and pages left out. Its
  side panel has the desktop's tabs but Claude's: Patterns, Pieces,
  Materials, Information Block, Notes, Output and Problems, with the
  desktop's keys. It prints through the browser and exports PDF, SVG and
  DXF-AAMA; Machine DXF stays on the desktop. Chrome and Edge save layouts
  back to their files and find a layout's files in a chosen folder. Work not
  yet saved is kept in the browser, and once loaded the app can be
  installed and works offline.
- An offset point's Properties have an *Offset by* row, to switch it between
  a length and angle and across and down. It stays where it is; its formulas
  become plain numbers, which Undo brings back. `convert_point` in the
  Automation API takes the same choice as `mode` (#146).

### Changed

- The design canvas's dependency arrows are solid and wider, with larger
  heads, so an arrow along an outline, such as from an offset point to the
  point it starts from, shows over the line. A piece's direction chevrons
  grow to match, on the desktop and the web (#145).
- Importing an SVG stamp never reads a document type's external files or
  expands its entities. A plain document type, as Illustrator writes, is
  ignored; one with an internal subset, or one that cannot be read, is
  refused with a message saying to save the drawing again without it (#90).

### Fixed

- A new, empty publish window no longer lists "Nothing is placed" as a
  problem; printing and exporting an empty layout are still refused (#152).
- In the web Design app, a drag or click right after an undo no longer fails
  with "There is no object or variable with ID …" when the undo took away a
  selected object (#133).

## 0.8.0

### Added

- The Properties tab shows what a point is placed from, after its name, for
  reading only: an offset point's base, the edge a point lies along and the
  end it is measured from, and so on (#116).
- A free or offset point can be placed from another point by dragging it
  with the Point tool: dropped on a point it is offset across and down from
  that point, and dropped in open space it becomes free, staying where it is
  (#115).
- Round Corner can fit an arc between a line and a curve or between two
  curves that share an endpoint (#54).
- Design Preferences can override the canvas colour, line pattern and width
  for each role, with a reset to restore that role's defaults (#56).
- A point's type can be changed in place, when it was placed the wrong
  way: select it, then what it is to be placed from, and choose the type
  in Tools → Points → Change To, or the *Change point to…* box in the web
  version. It becomes a free point, an offset, a point along an edge or
  between points, an intersection, a circle and edge, two circles or a
  projection, keeping its name, marker and everything that uses it. It
  stays where it is, or moves at most 10 mm onto its new edge or crossing,
  and the status bar says how far; formulas it had become plain numbers,
  which the formula suggestions can turn back into formulas.
  `convert_point` does the same in the Automation API (#81).
- The web editor imports SVG stamps at their original size. A stamp can
  hang from a selected point, edge or piece, or sit in the middle of the
  view. The drawing is saved in the pattern (#89).
- The web version's side panel has a Garment tab, as the desktop's: the
  pieces as sewn, darts closed and folds opened, shaded, of one material
  or all. Zoom with the wheel, drag to pan, double-click to fit, or follow
  the canvas; point at a piece to see it on the canvas, click it to select
  it there, and a selected piece or seam is marked. Export… downloads the
  view as SVG or as a PNG of the width you choose (#92).
- The web version's side panel has a Problems tab at the foot of its
  column, as on the desktop, with the number of problems on its icon.
  Choosing a problem selects what it is about on the canvas, or opens the
  Variables or Measurements tab at its row; pointing at one highlights it,
  and a double-click zooms to it (#93).
- The user guide explains formula suggestions, the wand beside a length,
  angle or ratio in the Properties tab (#80).
- Two tutorials that are not garments (#94). A tote bag: a lined bag sized
  by its variables, with boxed corners, a patch pocket and straps, a moved
  copy for the lining, rounded corners, placement lines and materials. A
  leather card wallet: one folded piece with no seam allowance, a thumb
  notch shaped by a curve's handles, and stitch holes made with a repeat.
  The wallet's pattern is among the examples, and in the web version's
  Examples list.
- A formula function, `bisect(a, b)`, gives the direction halfway between
  two directions, the shorter way round, so a point on a corner's bisector
  is `bisect(Chest_line.angle, Side_line.angle + 180)` rather than a long
  `atan2` formula. Two opposite directions are an error.

### Changed

- The Line and Curve tools draft a whole outline on their own (#114). After
  the first click, a click in open space makes a point across and down from
  the point before, not a free point, so the outline moves with its first
  point and each length can become a formula.
- The tote bag and card wallet tutorials draw their outlines with the Line
  tool alone, then set each point's length, and the tote bag ties its
  pocket to the body by dragging a point with the Point tool (#122). The
  finished patterns are the same; some points take other letters.
- The skirt and bodice block tutorials are simpler. Points take the names
  the app gives them, A, B, C and so on, in the order the steps make them,
  so you no longer name each one; most lines and curves keep their
  automatic names too. The variables come from Import… on the finished
  pattern, and a few lengths are taken from the formula suggestions rather
  than typed. The example patterns and the Features tutorials follow the
  new names (#80).
- The tote bag example is drafted in the order of its new tutorial, so its
  points have the app's names and its lining's copies end in `_t1` (#94).

### Fixed

- The web Design app starts with its side panel folded on narrow screens.
  The side panel button shows or hides it and remembers the selected tab (#91).
- Cancelling or leaving the web Seam tool clears pending edge picks (#97).
- An interrupted touch drag in the web editor rolls back without moving
  the object on the next click (#96).
- A failed file write in the web editor keeps the pattern dirty and preserves
  its recovery copy (#95).
- The web engine reports a worker call failure to the request that caused
  it. If the worker stops, pending requests report the failure instead of
  leaving controls waiting indefinitely.
- `opensloper-cli export-draft --upto` stopping before a transform, or at
  it, no longer fails on the transform's copies: they are left out or kept
  with it (#94).

## 0.7.0

### Added

- Import Variables: the Variables tab's Import… button, or File → Import
  Variables…, adds the variables of another pattern file in one undo step,
  so values set up once, such as your usual eases, need not be typed again.
  A variable the pattern already has is kept, never overwritten, with a
  warning when the file's formula differs: delete it and import again to
  take the file's. Both patterns must be in the same unit.
  `import_variables` does the same in the Automation API, from a path or
  the file's contents (#79).
- The skirt and bodice block tutorials can import their variables from the
  example pattern instead of typing them in (#79).
- While a field's formula suggestions are open, with Contextual labels the
  canvas also labels the points and edges the suggestions in view name,
  such as `Side_seam` in `Side_seam.angle`; scrolling the list changes
  them. None still shows no labels (#82).
- In the Automation API, `open` takes a pattern file's contents as `text`
  in place of a path, `save` can give the contents back as `text` instead
  of writing a file, `use_measurements` takes a measurement file's
  contents, and the document's details give `measurementsFile`, the
  measurement file's name as the pattern records it.
- A first preview of the web version of the design app (#78), built from
  the source with `opensloper-make.sh web`; it is not hosted yet. The
  pattern engine runs in the browser as WebAssembly, and files stay on
  your computer. It draws and edits patterns with the desktop's tools,
  side panel tabs (Properties, Objects, Variables, Measurements,
  Materials and Features), formula completion and suggestions, undo and
  redo; opens and saves files in place where the browser allows, keeps
  unsaved work in the browser, works offline as an installable app, opens
  the user guide's examples, exports the draft as SVG and prints tiled
  PDFs.

## 0.6.0

### Added

- A dart in the Features tab: choose an edge of a piece, and a point to run
  to if you like, and Apply adds the dart's points and legs in place of the
  edge between them, a seam closing it, notches, a hole near the point and
  the centre line as a fold, in one undo step. Its seam allowance has a
  cap, the shape of the dart pressed to one side, so it sews into the seam;
  a dart drawn by hand can have one too, under Cap on in the piece's
  properties. `feature_dart` and `set_dart_cap` do the same in the
  Automation API (#72).
- A hem in the Features tab: select the edges to hem, on one piece or
  several, choose single, double, narrow or blind, and Apply gives them the
  hem's allowance, topstitching inside the piece and a notch where it turns
  up, in one undo step. The depth is `#hem_depth`, which every hem shares.
  The hem's allowance ends mirror the edges beside it, so a flared hem lies
  flat turned up; any edge can have mirrored ends under Mirrored ends in the
  piece's properties. `feature_hem` and `set_allowance_end` do the same in
  the Automation API (#73).
- A tutorial, Adding a hem, hems the skirt block's front and back from the
  Features tab in one step (#73).
- A facing in the Features tab: select a neckline, an armhole or an
  opening, on one piece or several, and Apply adds the facing's inner edge
  at its width, the facing piece cut as the piece is, a seam joining it to
  the piece, the piece's notches along it and a seam between facings where
  their pieces are seamed, such as at the shoulder, in one undo step. The
  facing can be drawn over the piece or beside it, with an interfacing if
  you like. The width is `#facing_width`, which every facing shares.
  `feature_facing` does the same in the Automation API (#74).
- An offset edge's ends can be limited by edges: each is cut back to where
  it crosses its edge, or carried on straight to it (#74).
- A tutorial, Adding a facing, faces the bodice block's front and back
  necklines from the Features tab in one step (#74).
- Buttons in the Features tab: select a front opening's edge, and the other
  front's too if they are separate pieces, and Apply adds the first and
  last buttons' points, a repeat of buttonholes and one of buttons between
  them, and an extension past the edge if you like, the edge staying as a
  placement line, in one undo step. The size, thickness and count are
  `#button_size`, `#button_thickness` and `#button_count`, so changing the
  count moves and adds buttons and holes. `feature_buttons` does the same
  in the Automation API (#75).
- A buttonhole point marker: a slot its size long with bar tacks, at an
  angle and moved along it by an offset, cut as a slit by machines
  (#75).
- A tutorial, Adding buttons, opens the bodice block's front and buttons
  it from the Features tab, with a facing behind the buttons (#75).
- A facing can go behind a button extension: its inner edge leaves out a
  short step the width swallows, and runs on past a short edge within the
  width, which the facing takes whole, to the edge it meets (#75).
- A tutorial, Adding a dart, puts a second dart in the skirt block's back
  from the Features tab and caps every dart (#72).

- A tutorial, Adding a zip, puts a zip in the skirt block's centre back
  from the Features tab (#76).

## 0.5.0

### Added

- Privacy for the Claude tab and any AI assistant connected to the design
  window: they are never given a folder or the measurement file's name, so
  nothing sent puts a name to the measurements, and **Let AI assistants read
  the measurements** in Edit → Preferences → Design keeps the measurement
  values back. The Claude tab says what is sent before the first question,
  and the user guide's Asking Claude and Scripting pages have a Privacy
  section (#60).

- A Problems tab at the foot of the side panel, in the design and publish
  apps, lists every problem in full with the count on its icon. Clicking
  one selects the object, piece or note it is about; in the design app
  pointing at one lights its object and double-clicking zooms to it.
  Clicking the status bar's problems count opens the tab (#61).

- Formula suggestions for a free point's x or y now offer another point's
  coordinate (`B.x`) and the point halfway between two points
  (`(B.x + C.x)/2`), the ends of an edge first.
- While the suggestion list is open, a point can be dragged along a field
  that holds a formula: the drag puts a plain number in its place, in the
  same undo step, so moving the point finds a better formula.
- An Icons page in the user guide's reference lists every command each app
  shows an icon for, with its menu, keys and what it does (#46).
- The Drawing page shows how to bisect a corner with an offset point.
- Piece and size fields in note text (#50): a note that prints with a piece
  can show `{piece.name}`, `{piece.cut}` ("cut 2 on fold") and
  `{piece.material}`, and any note or sheet note the size chosen from a size
  table, `{size}`, so a note can be a piece label of your own.
- Once a pattern has a piece, an outline edge that no piece uses is listed
  as a problem, since it does not print (#51).
- Problems are drawn on the canvas (#51): every object with a problem has a
  faint red halo, and pointing at it says what is wrong. View → Problems turns
  the halos off and on.
- Dependency arrows (#52): pointing at or selecting a point or edge draws
  faint arrows to the points and edges it is built from, and, with View →
  Dependents on, to those built from it.
- A note on the canvas follows its text as it is typed, values worked out,
  and double-clicking a note goes to its text, opening the side panel if it
  was hidden (#53).
- The Garment tab draws fold lines, such as pleats, as lines on the pieces
  (#55).
- A Features tab in the design app's side panel adds sewing details in one
  step. Its first is a zip along a piece's edge, centred, invisible, lapped
  or fly front: Apply adds the stop point, splits the edge there, widens the
  opening's allowance, notches the stop and adds the style's topstitching,
  with a fly shield piece for a fly front, as ordinary objects that one Undo
  takes off. Its length is the `#zip_length` variable, so zips can share it.
  Scripts and assistants add one with the API's `feature_zip` (#63).
- Developer documentation of the code, made by PasDoc from the comments in
  the sources with `./opensloper-make.sh devdocs`; it is built locally and
  not yet published (#47).
- Pack pieces nests the pieces by their shapes rather than the rectangles
  round them, so a small piece can go in the curve or notch of a larger one,
  at least 10 mm apart; the circle skirt example tiles on 20 A4 pages rather
  than 23. Material needed still packs rectangles (#58).
- A Claude tab in the publish and drape apps. In publish, Claude places,
  turns, flips and packs pieces, sets what the layout prints on and adds
  notes and the information block; in drape, it places, turns, flips and
  aligns pieces round the body and guesses placements. It can look at the
  sheet or the body as a picture, each change is one step to undo, and it
  cannot save, export, print or run Blender. The tab says what is sent to
  Anthropic before the first question (#64).
- The drape app, `opensloper-drape`, places the pieces of one or more
  patterns round a figure built from the measurements, and drapes them in
  Blender's cloth simulation (File → Drape in Blender…, or
  `opensloper-cli drape --run`). Open it from the design app with File →
  Drape… (Ctrl+D). An edge can be attached to the body, so a skirt's
  waist holds it up, and with no body an attached edge holds a bag up where
  it is placed; the figure's arms can be left out, so a full skirt does not
  catch on them. Every example pattern has seams and a drape file to start
  from (#11).
- Materials have a **Fabric**, cotton, silk, jersey, wool, denim, canvas or
  leather, which sets how their pieces drape in Blender: their weight and
  how stiff they are. It is in the Materials window and the API's
  `add_material` and `set_material`; a material without one drapes as
  cotton. The tote bag example is canvas, lined with cotton (#11).

### Changed

- The Anthropic API key and **Let AI assistants read the measurements** are
  on the General tab of Edit → Preferences rather than Design, since every
  app's Claude tab uses them. Assistance → Anthropic API Key… in the design
  app opens that tab (#64).

- Move Copy starts with the copies just right of the originals, rather than
  hidden on top of them, and after any transform the canvas brings the
  originals and copies into view (#49).
- The publish app's side panel is in the order it is used: Patterns,
  Pieces, Materials, Info and Notes, then Output just above Problems.
- The side panels of the design and publish apps have a column of tab icons
  down their left instead of a header for each tab, so the open tab has the
  panel's full height, under a title with its icon and name. The Problems
  icon stays at the foot with the count on it, and clicking the open tab's
  icon folds the panel down to its icons (#62). The Icons page lists each
  tab's icon under Side panel tabs.

## 0.4.0

### Added

- Formula suggestions (#26): a wand beside a field holding a plain number
  or a formula lists formulas that give about the same value, such as
  `@waist/4` for an offset of 175 mm, built from measurements, variables and
  other edges' lengths and angles, closest and simplest first. Hovering one
  shows where it would put the point; choosing one writes it into the field.
  While the list is open on a plain number, dragging the point or nudging it
  with the arrow keys changes only that field, along a guide line, and the
  list follows the value.
- With a size table, each suggestion also shows its values at the smallest
  and largest sizes and, in its tooltip, at every size, and hovering it
  outlines the pieces at those two sizes, so a formula that matches only by
  chance stands out (#26).
- The Python client has `OpenSloper.create_pattern_file`, which writes a new,
  empty pattern file to open, in a chosen unit and with a measurement file,
  so a script no longer writes the file's JSON itself (#44).

- Ctrl+Tab and Ctrl+Shift+Tab, also Edit → Select Next and Select
  Previous, step through the objects the Objects tab lists, keeping the
  cursor in the field being edited, so formulas can be looked through
  without the mouse (#39).

### Changed

- A unit is refused where no unit belongs (#33): `45mm` as an angle, or
  `@waist / 4 + 1in` as a share along an edge, now says why instead of being
  taken. Lengths that cancel out, such as `Hem.length / 10cm`, are still fine,
  and patterns already saved open as before.
- Pattern, measurement and layout files are versioned (#42): the apps read a
  file of any older version, bringing it up to date as it loads, and save it
  at the current version. A file claiming a version below 1 is refused with
  the reason. All three formats are still at version 1.
- The user guide has moved to <https://docs.opensloper.com>; Help → User
  Guide, the Python client and the file schemas link there (#43).


## 0.3.0

### Added

- Installers: a `.deb` for Debian and Ubuntu, a `.dmg` for macOS and a
  `setup.exe` for Windows, each registering the pattern, measurement and
  layout files with their apps (#17). The `.tar.gz` and Windows `.zip` stay
  for running from a folder; the macOS `.zip` is replaced by the `.dmg`.
- Every download has the user guide to read offline, and Help → User Guide in
  each app opens it, or the website when the guide is not there (#17).
- A change of preferences reaches the apps already open, without a restart
  (#29).
- A portable install: with a `portable.ini` beside the programs (beside
  `OpenSloper.app` on macOS), settings, recent files and cache are kept in a
  `user` folder beside them and documents in `documents`, and recent files
  there are still found when the drive gets another letter (#30).

- The Claude assistant works on Windows and macOS: their downloads bring
  OpenSSL 3 and Mozilla's root certificates (#31). On Linux it finds the
  system's OpenSSL 3 without the development files, and the `.deb` depends on
  it.
- `opensloper-cli check-connection` says whether the assistant can reach the
  API: that OpenSSL loads, the server's certificate is trusted and it answers
  (#31). The release jobs run it from each download.

### Changed

- The Automation API's `export` refuses to replace a file already there, and
  `set_measurement` asks before it writes the measurement file.
- The Claude assistant checks the server's certificate before sending the API
  key.
- The assistant's conversation ends when another pattern is opened.
- The assistant keeps only its last three draft images in the conversation.
- A tiled print is capped at 10,000 pages; past that the layout has a problem.
- A draft PNG is capped in height, and an empty area is refused.
- Pieces that packing cannot fit are set below the packed ones.
- `opensloper-cli materials` warns about each pattern it could not read and
  exits 2.
- `opensloper-cli layout` refuses a pattern file that is not there.
- Patterns, layouts, measurements and settings are written atomically.
- The measurement and layout undo keep the latest 500 steps.
- File → Save As starts in the pattern's own folder.
- Files ending `.SLOPER` or `.SLAYOUT` are known whatever their case.
- The evaluation graph is built in linear time, and formula references are
  looked up rather than compared with every object.
- An edge is measured once for a repeat, and once when finding coincident
  edges.
- A layout's pieces are placed once when listing its problems, and a garment
  piece is fingerprinted without flattening its edges again.
- The list panels rebuild once a drag ends, and the publish Materials tab
  only when the patterns change.
- Unit conversion tries a number's plain fit once.
- Messages name an input of the wrong kind rather than give its ID.
- The test square's printed size is translatable.
- The design window's actions and toolbars are built with the code the other
  apps share.
- The MCP server and the assistant share their tool result code.
- One array type and one vector normalising function serve all the geometry.
- The design form's `ui_state` answer is named `UIStateJSON`, so it no longer
  hides the form's own `WindowState`.

- The design app's Claude commands are in a new Assistance menu: Ask Claude,
  Anthropic API Key…, Allow Assistants to Connect and Disconnect Assistant.
  Any MCP client can connect, so the window, its consent prompt and its undo
  steps say "assistant" for them; the Claude tab keeps Claude's name, and its
  question box and buttons are off until an API key is set (#37).

### Fixed

- An API edit left open by a method that fails is cancelled.
- A malformed API request without an id gets no reply.
- An API call's repeat point gets its ID inside the call's change.
- An API input given by an ID that does not exist is refused.
- `set_material` names the parameter in its number errors, and `add_point`
  lists every point type.
- An assistant question stopped before any answer is taken back.
- An assistant stream cut off before its end is treated as failed.
- A key changed in Preferences is used on the assistant's next question.
- Stop ends the assistant's request at once.
- The assistant says why its key file could not be saved or removed.
- A reset connection to the Claude API no longer ends the design app.
- JSON nested too deep to parse safely is refused.
- Numbers past a double's range are refused in files, formulas and imported
  measurements.
- IDs from files are kept within 32 bits.
- A transform's sources are read as IDs, not any number.
- A fragment's odd selection or needs is refused instead of raising.
- How deep an imported Seamly formula is worked out is limited.
- A pasted ID from another pattern that the copy does not hold is refused.
- A node is made invalid when a number too large raises as it computes.
- A repeat's count is checked before it is rounded.
- A curve is offset all along when a handle has zero length.
- Two close crossings of large circles are told from a touch.
- Every perpendicular foot on a curve is found, not only the nearest point.
- A curve's crossings are found however close, and where it only touches.
- A repeat is collected once when a piece uses several of its points.
- A point keeps its marker when its operation is changed.
- A point given twice is arranged once.
- A marking a piece's formula also reads cannot be deleted.
- A transform whose copy a piece only marks can be deleted.
- A round corner given the same edge twice is refused.
- A mirror's second axis point is checked when it is made.
- A mirror's axis line cannot be turned into a curve.
- A projector sheet draws in white again after a profile-coloured line.
- The sheet and its pages are sized for the notes printed with pieces.
- Each material and measurement set is listed once, matched whole.
- Nothing is placed for a tray item whose piece has gone.
- New pieces wrap at the roll or material width.
- A fold piece keeps its half when opening it out encloses nothing.
- A repeat is deleted when one of its points is selected.
- Align says why it did nothing when a locked point would move.
- Hidden and dimmed pieces are left out of click choices.
- A pending pick and tool state are dropped when another pattern opens.
- The Garment tab keeps its material and view through undo.
- The formula caret is right with letters beyond ASCII.
- A piece's colour choice starts on its own material's colour.
- `--upto` draws up to a repeat when it names one of its points.
- A layout's `-m` path is stored relative to the layout.
- A pending measurement conflict is dropped when another file is opened.
- Only text names are read from the catalogue's name lists.
- The measurement text that was loaded is remembered, not read a second time.
- The Lines panel no longer outlives the document when the design
  window closes.
- A publish drag no longer loses the piece it moves.
- A header or cell edit is finished before switching measurement files.
- The title fields keep their order when one is ticked or cleared.
- A plain bracket before a link no longer garbles the Python client's
  docstrings.

### Removed

- The hidden Align tab of the design app. Points are lined up and spaced out
  by their formulas and by Tools → Points → Repeat Points; the Automation
  API's `arrange` stays (#36).

## 0.2.0

### Added

- The Garment tab in the side panel shows the pieces as sewn (#4): darts made
  seams are closed, pieces cut on the fold are opened, and each piece is shaded
  as if round a body, arranged as on the canvas. Hovering a piece shows it on
  the canvas and a click selects it there; a selected seam is marked on both
  its sides. It exports SVG and PNG, the Automation API's `render` draws it
  with `garment`, and Preferences set its light.
- Objects can be locked (#16) with Edit → Lock and Unlock, or Locked in the
  Properties tab. A locked object is drawn greyed and cannot be moved, edited
  or deleted, but it can still be selected and used, and its formulas still
  run. The lock is saved with the pattern and is one undo step; the
  Automation API has `set_locked`.
- Overlapping pieces can be hidden, isolated and stacked (#10), from the View
  menu. Hide Piece takes a piece off the canvas with what only it uses; Isolate
  Piece dims everything the piece does not use and puts it out of reach; Bring
  to Front and Send to Back change the drawing order. They are saved with the
  pattern, outside undo, and the Garment tab and Export Draft follow them;
  every piece still prints.
- Notes and sheet notes have a font, bold and italic (#7). The canvas draws
  the font, SVG names it, and PDF embeds it from its TrueType file, cut down to
  the letters used. A font that cannot be embedded prints in the default font,
  with a warning.
- Materials have a size and the material needed is worked out (#19). A
  material can have a width (a roll) or a width and length (a sheet), and can
  allow quarter turns when it has no grain. A piece too big to cut from its
  material is a problem in the design app, `check`, the CLI and the API, each
  piece measured along its grainline. The publish app works out how much of
  each material the layout's patterns take, a roll cut folded in half
  lengthwise and a sheet single layer, and shows it on a new Materials tab, in
  the information block's Material needed line and the `{materialneeded}`
  field; `opensloper-cli materials` prints it. Choosing a material for a
  material sheet takes that material's size. The Automation API's
  `set_material` takes `width`, `length` and `allowTurns`.

### Changed

- The development scripts are one, `opensloper-make.sh`, with the commands
  `test`, `build`, `check`, `format`, `docs`, `package` and `release` in place
  of `run-tests.sh`, `build.sh`, `check-standards.sh`, `format.sh`,
  `build-docs.sh`, `package.sh` and `release-notes.sh` (#22).
- File → Publish… in the design app brings the publish window already showing
  the pattern's layout to the front, rather than opening another each time
  (#18). Only when none shows it is a new one started.
- Menu and toolbar commands are greyed out while they cannot be used (#24),
  in all three apps. A new, empty file has nothing to save, export, print or
  publish; Save waits for a change; and the commands that work on a
  selection, a measurement row or a size column wait for one. Cut, Copy and
  Paste stay on, as they also work in text fields.
- The publish app's Notes tab is two (#14): Information Block, the title
  block renamed, whose Show box turns it on, and Notes. The pages show the
  information block where it prints, with the cover drawn left of the tiles.
  Sheet notes have a frame round them on screen, so they are easy to find,
  and clicking one opens its details on the Notes tab.

### Fixed

- Angles worked out from points (`AngleBetween`, `NormalizeAngle`) were only
  good to about seven figures, as Free Pascal's `FMod` took its
  single-precision form.
- PDF prints text outside Latin-1, such as Greek or Cyrillic, in sheet notes,
  piece labels and notes, in the bundled Noto Sans; it used to print `?`.
- The publish app's Print dialog sizes itself to its contents once shown; with
  a larger font its note was cut off at the bottom.
- The Preferences dialog sizes itself to its contents once shown, within the
  screen, and each tab scrolls when the screen is too small (#12); with a
  larger font the bottom of the Design tab was cut off.
- The publish preview drew sheet notes a quarter larger than they print, and
  their lines further apart.

## 0.1.0

The first release, for trying out: features and file formats may still change.

### Added

- **opensloper-measurements**: one person's measurements or a size table, from
  a catalogue of measurements with body figures.
- **opensloper-design**: points, lines, curves, circles and rectangles placed by
  formulas, in mm, cm or inches; pieces with seam allowances, seams, notches,
  markings, grainlines and materials; transforms, notes and callouts; full undo.
- **opensloper-publish**: pieces laid out on tiled pages, a large sheet, a
  projector or a material width, printed at true size or exported as PDF, SVG
  or DXF.
- **opensloper-cli**: checks and exports patterns and layouts, and serves the
  Automation API, also as an MCP server, so scripts and Claude can draft.
- Ask Claude about the open pattern from the design window's side panel.
- A Zoom tool (Z) in the design window and Zoom Area in the publish window:
  drag a box to zoom to it (#3).
- Zoom In and Zoom Out in the publish window, and Ctrl++ for Zoom In in both;
  Ctrl+= still works (#3).
- Scroll bars on the publish preview (#6).
- Downloads for Linux (x86_64), macOS (Apple silicon) and Windows (x86_64).
