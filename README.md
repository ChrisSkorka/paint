# paint

Simple Image & GIF Editor

## design

### principles

- ms paint style pixel editor
- simple & basic
- basic timeline functionality for animations

### visuals

- single page
- tabs
  - new document
    - create new (name, size in pixels)
    - create from clipboard
    - open from real file (ora, png, jpg)
    - document list from in-app storage (open, delete)
  - editor
    - top panel: MS Paint style panes
      - file
        - save (in-app storage) & export (real file)
        - undo & redo
      - selection
        - copy, cut & paste
        - rotate (90d) & mirror horizontally & vertically
      - tools
        - pen
          - square: hard edge, size configurable
          - circle: hard edge, size configurable
        - eraser: hard edge, size configurable
        - color picker
        - bucket fill
        - select
        - shapes: rectangle, circle, line (width from tool config)
      - colors
        - primary & secondary current colors
        - recent colors swatches (5)
        - grey scale swatches (5)
        - hues * brightness swatches (5*12)
        - color picker (rgba)
    - right panel
      - layers
        - image preview
        - visibility toggle
        - transparency slider
        - timeframe mode (constant/image per frame)
      - history
    - bottom panel
      - cursor pixel position
      - timeline
        - play/pause button
        - slider
      - zoom
    - canvas

### technical

- panes in the top & right panels are interchangeable components
- tools
- canvas
  - background: light grey transparency chess grid pattern
  - layers support transparency
- file formats
  - ora (OpenRaster): native format, keeps layers, names, visibility & opacity, includes merged image & thumbnail
  - animations stored in ora via namespaced extensions (per-frame layers as stacks, frame durations), other apps show frame 1
  - png & jpg: open as single layer, export flattens visible layers (jpg onto white)
  - gif: animation import & export
- documents have a name: entered when creating new, file name when opened from file
- saving
  - save: explicit only (no autosave), writes to in-app storage, `ctrl+s`
  - files opened from disk are not copied to in-app storage until first save
  - unsaved changes indicator reflects in-app storage status
  - export: writes a real file (save dialog on desktop, download on web), does not affect the indicator
- in-app storage
  - `DocumentStore` interface, platform implementation picked via conditional import
  - desktop: `<app support dir>/documents/<id>.ora` + `index.json` (name, modified time, thumbnail)
  - web: IndexedDB via `idb_shim` (in-memory factory for tests)
  - mobile: not supported yet, added later as another implementation
- platforms: desktop (linux, windows, macos) & web
- application id: `info.skorka.chris.paint`

## project structure

- lib
  - editor
    - files
    - tools
    - canvas
  - widgets
    - components
    - views
- test
  - unit (purely stub/mock/fake dependencies/children)
    - <mirror lib sub structure>
  - integration
    - <mirror lib sub structure>
  - end-to-end (only test top level entry points)
    - <mirror lib sub structure>
  - support: reusable mocks and fakes
    - <mirror lib sub structure>

## style (copied from POC)

- layout: column of top bar, canvas area, bottom bar; right panel added beside canvas
- font: Arial / sans-serif
- bars & panels
  - background `#F8F8F8`, shadow `0 0 5px rgba(0,0,0,0.1)`, vertical padding 5
  - z-order: top bar > bottom bar > canvas area
- canvas area
  - background `#EEEEEE`, padding 12, scrollable both ways
  - nearest-neighbour scaling (`FilterQuality.none`), system cursor hidden, brush outline drawn as pointer
- ribbon sections (top panel panes)
  - small centered title above content, color `rgba(0,0,0,0.7)`
  - content height 80, laid out in columns
    - single column: one 80 tall button
    - double column: two 40 tall buttons stacked
  - sections separated by a 1px `rgba(0,0,0,0.1)` right border, padding 5
- icon buttons
  - transparent, radius 5, padding 8×12, icon color `#444444`
  - hover & selected: background `rgba(0,0,0,0.03)`, border 1px `rgba(0,0,0,0.1)`, faint shadow, 100ms transition
  - disabled: no hover effect
  - split buttons (tool + chevron dropdown): joined, inner corners square, hover highlights both halves
  - tool icon tints: pen `darkorange`, eraser `indianred`, fill `blueviolet`, color picker `dodgerblue`, save `deepskyblue`
  - Font Awesome icons (`font_awesome_flutter`): house, rotate-left/right, floppy-disk, download, crop-simple, rotate, pencil, eraser, fill, eye-dropper, border-top-left, angle-down
- color swatches
  - 15×15 cells, 1px gap, outer corners of the grid radius 5
  - hover: scale 1.8, white 2px border, radius 4, shadow, drawn above neighbours
  - greys: `#ffffff #bfbfbf #808080 #404040 #000000` (1 column × 5 rows)
  - hues: 12 columns (every 30°), 5 brightness rows, see `POC/js/WebComponents/PaintController.js`
- inputs (number, text) & dialogs/dropdowns
  - white background, 1px `rgba(0,0,0,0.3)` border (dialogs `0.1`), radius 5, padding 8×12, faint shadow
  - focus: border `rgba(0,0,0,0.5)`, slightly stronger shadow
- primary / secondary color: 40 wide swatches with 1px black border, radius 5
- bottom bar: sections with right border (cursor position, canvas size), spacer, zoom control
  - zoom control: `Zoom:` label, number input, minus, slider, plus
  - slider is logarithmic (`log2`), range 0..4 (1×..16×), number input allows 1..100

## phases

Each step lands with unit tests for `lib/editor` and widget tests for `lib/widgets`, passing the pre-commit hook (analyze, format, 100% line & branch coverage).

### phase 1: minimal drawing POC, single layer, no history

#### 1.1 foundation

- [x] app shell: single page with `new document` and `editor` tabs
- [x] theme & shared components from the style section: ribbon section, icon button, split button, dropdown, swatch grid, numeric value range
- [x] editor model (`lib/editor`, pure Dart): document (width, height, list of layers, active layer index, created with one layer), layer (RGBA pixel buffer), color, point & rectangle
- [x] new document tab: create new with width & height in pixels

#### 1.2 canvas & drawing

- [x] canvas widget: renders layers over the transparency chess grid, pixelated, at zoom level
- [x] pointer mapping: screen position → pixel position, primary (left) & secondary (right) button
- [x] tool interface: start, stroke, end, draw pointer; draws on the document's active layer and reports the altered area (used by history in phase 2)
- [x] pen: square & circle tips, hard edge, configurable size, line interpolation between pointer events
- [x] eraser: hard edge, configurable size
- [x] bottom panel: cursor pixel position, canvas size, zoom control

#### 1.3 colors

- [x] primary & secondary colors, left click draws primary, right click draws secondary
- [x] swatches: greys (5), hues × brightness (12×5), recent colors (5)
- [x] rgba color picker dialog
- [x] color picker tool: sample pixel into primary / secondary
- [x] color picker dialog: hex input field

### phase 2: full editor, no files IO, clipboard, or animations

#### 2.1 history

- [x] history stack of altered-area snapshots per action
- [x] undo & redo buttons in file pane, `ctrl+z` & `ctrl+y`
- [x] history pane in right panel: list of actions, click to jump

#### 2.2 more tools

- [x] bucket fill (4-connected, exact color match)
- [x] shapes: line, rectangle, circle, outline width from tool config, outline centered on selection edge, preview while dragging
- [x] select: rectangle selection, move contents, rotate 90°, mirror horizontally & vertically, delete key performs eraser on selection

#### 2.3 layers

- [x] layers pane in right panel: preview, visibility toggle, transparency slider
- [x] add, remove, reorder layers, select active layer
- [x] history records layer changes: add, remove, reorder, visibility, transparency

### phase 3: clipboard

- [x] copy, cut & paste selection to / from system clipboard
- [x] paste into new layer when larger than selection
- [x] create from clipboard (new document tab)

### phase 4: files & persistence

- [x] application id `info.skorka.chris.paint` (linux, macos, windows, web)
- [x] decode & encode png & jpg (`image` package), flatten visible layers on export
- [x] decode & encode ora: layers, names, visibility, opacity, merged image & thumbnail
- [x] document name: name field when creating new, file name when opened from file
- [x] open from real file (new document tab), export to real file (file pane, `file_selector`): save dialog on desktop, download on web
- [x] in-app storage: `DocumentStore` interface, desktop files in app support dir, web IndexedDB (`idb_shim`)
- [x] save to in-app storage (file pane, `ctrl+s`), document list in new document tab (open, delete)
- [x] unsaved changes indicator (in-app storage status)

### phase 5: animations

### phase 5.1: frames & timeline

- [x] document frames & frame duration in model
- [x] layer timeframe mode: constant (shown in every frame) or image per frame (set per layer)
- [x] timeline in bottom panel: play / pause button, frame slider, add / remove frame
- [x] gif import (frames → image-per-frame layer) & export
- [x] save animations in ora (namespaced extensions: per-frame layers as stacks, frame durations)

### phase 5.2: rich controls

- [x] ribbon (top)
  - row 1: prev frame, play/pause, next frame, FPS, onion skinning input
  - row 2: slider, #/# indicator
- [x] frames pane (right side)
  - list item: number, holds input, frame preview
  - controls: plus (create blank), copy (clone selected), delete, move up, move down
  - item is selected when it's frame is shows (follows during playback)
- [x] onion skinning: 
  - onion skinning input: toggle button with dialog
  - dialog: toggle prev frames, toggle next frames, frame counter
  - renders visible per-frame layers from adjacent frame
  - renders {frame counter} of each prev & next frames
  - adjacent frames render with opacity starting at 50% halving for each consecutive frame 
  - previous frames are red tinted
  - next frames are green tinted
  - off during playback
- [x] frame holds
  - replace per-frame durations with global FPS
  - GIFs frame durations are rounded (held frame durations are rounded before multiplying by holds)
  - holds input: + & - button with number between
  - allow 0 to disable/hide frame
  - zero-hold frames are excluded from playback, GIF export, onion skinning, and #/# counter (but rendered when exporting images on that frame)

### phase 6: editor refinements

### phase 6.1: keyboard shortcuts

- [x] shortcuts for tools
- [x] shortcuts for animations
- [x] shortcuts for layers
- [x] shortcut list on new doc page

### phase 6.2: tool history & favorites

- [x] bottom bar has list of recently used tool-config combinations & favorites
- [x] each option is a row with: 
  - split button: 
    - icon of tool
    - column with saved properties (small text & icons)
    - secondary action: lock/unlock
- [x] tools to include: pen, eraser, fill, shapes
- [x] properties to include:
  - color: shows as tool icon color
  - size: shows as `# px` in properties column
  - tip: shows as icon in properties column
- [x] locking mechanism:
  - locked items are first, rest is history in order of use
  - when locking, item is moved to end of locked list before other recent items
  - when unlocked, item is moved to start of recent list
  - recent items don't include locked items
- [x] shortcuts: 1-9 for items respectively
- [x] remove last 5 color column from color ribbon
- [x] save favorites & recent to ora doc: `<paint:tools><paint:tool kind="pen" color="#ff0000ff" size="4" tip="round" locked="true"/>...`

### phase 6.3: multi document editing

- [x] tabs: multiple documents, feel like browser tabs
- [x] tab: starts as new document, then converts to editor
- [x] tab list has a + option at end that creates new tabs
- [x] tab title is document name
- [x] has a dot when doc has unsaved changes
- [x] tabs have close button
- [x] closing unsaved doc triggers confirmation dialog
- [x] shortcuts: ctrl+N
- [x] middle mouse click on tab closes tab (or prompts when unsaved)

### phase 6.4: layout

- [x] right pane goes to top of canvas, not top of tab
- [x] right panels are collapsible
- [x] right pane is resizable
- [x] bottom bar items have constant width (currently cursor position and save status shift elements)
- [x] top ribbons are collapsible, when collapsed title is sideways

### phase 6.5: sizes & scrolling

- [ ] vertically scrollable views always show scroll bars (& scroll bars are touchscreen friendly thickness) (but only content overflows)
- [ ] allow scrolling document/canvas to the right & bottom when smaller than available space (currently if smaller, it's constraint to top left corner)
- [ ] horizontally scrollable views (top ribbons & tabs as far as I know) scroll on scroll wheen without needed shift pressed

### phase 7: tool refinement

### phase 7.1: pen ribbon

- [ ] pen ribbon: split size & tip into own ribbon
- [ ] ribbon between shapes & colors
- [ ] pen, eraser, and shapes use same settings
- [ ] transparency mode for transparent color & selections?

### phase 7.2: shape tools

- [ ] better defaults
- [ ] shape tool: constraint to square/level when ctrl is pressed
- [ ] shape tool: fill with secondary color

### phase 7.3: text tool

- [ ] text tool: above selection tool
- [ ] options: size (not using pen size)
- [ ] using pen color
- [ ] font: whatever the app uses, no config needed
- [ ] shortcut: T

### phase 7.3: colors

- [ ] colors: add no-color option, no-color button below dialog button
- [ ] color picker: better UI
- [ ] transparent colors: blend mode

### phase 7.4: history

- [ ] history & layer item preview enlarges on hover
- [ ] history slider
- [ ] feature to convert history diff into layer

### phase 8: polish

### phase 8.1: performance

- [ ] check memory consumption & performance of history stack
  - a 4096*4096 canvas is unusable
- [ ] history stack memory management
  - [ ] stack limit
  - [ ] or progressive history item merging
  - [ ] image compression (package:archive, XOR against previous layer)

### phase 8.5: image properties

- [ ] allow change image size
- [ ] allow renaming documents stored in-app

### phase 8.7: misc

- [ ] move image previews to left of layer, frames & history items
- [ ] text inputs have unit text on right side
- [ ] right click on web triggers system context menu
- [ ] save real file when opening real files on native system
- [ ] allow renaming layers
- [ ] allow zoom less than 1x
- [ ] default zoom fit's doc
- [ ] new docs tab: in-app docs have duplicate button

### phase x: todo

- [ ] animation loop toggle
- [ ] interchangeable panes: move panes between top & right panels
- [ ] wide double buttons for pairs: undo/redo, rotate, mirror

### phase y: vector graphics

- docs are either pixel or vector type
- tools
  - node
  - pen
  - corner
- shapes
  - line
  - arrow
  - square
  - circle
- actions
  - add
  - subtract
  - intersect
  - xor
  - divide?
- selection
  - copy, cut, paste
  - rotate left & right
  - mirror horizontally & vertically
  - select all
- color: same as pixel editor
- object properties panel
- animations: same as pixel editor

