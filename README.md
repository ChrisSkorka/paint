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
- [x] macos shortcuts
  - swap ctrl & cmd
  - show cmd in shortcut hints
- [x] ctrl/cmd + scroll zooms in & out
- [x] alt + scroll scrubs through timeline/frames (& loops)

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

- [x] vertically scrollable views always show scroll bars (& scroll bars are touchscreen friendly thickness) (but only when content overflows)
- [x] allow scrolling document/canvas to the right & bottom when smaller than available space (currently if smaller, it's constraint to top left corner)
- [x] horizontally scrollable views (top ribbons & tabs as far as I know) scroll on scroll wheen without needed shift pressed
- [x] button and scroll zoom step by 1 instead of x2
- [x] allow zoom less than 1x (1/2, 1/3, 1/4, ...)
- [x] zoom centered on canvas center except on scroll, then center around cursor
- [x] default zoom & ctrl+0 fit's doc centered in canvas
- [x] exponential zoom step sizes:
  - internal representation is still int
  - negative numbers represent fractional zooms (-2 => 1/2, -10 => 1/10)
  - number input allows any integers
  - buttons and scroll use a size step method similar to toolSizeStep
  - step sizes rules:
    - < +- 4: 1
    - < +- 8: 2
    - < +- 16: 4
    - < +- 32: 8
    - ...

### phase 7: tool refinement

### phase 7.1: pen ribbon

- [x] pen ribbon: split size & tip into own ribbon, tools no longer have that dropdown/popup
- [x] ribbon between selection & tools
- [x] pen, eraser, and shapes use same shared pes settings
- [x] eraser & shapes support also support round tip
- [x] pen tool settings are disabled if the current tool doesn't support that setting (e.g. fill, color picker, & select have all of them disabled)
  - [x] line, arrow, and square shapes produce different results with different tips (e.g. rounded rectangle) but circle tool wouldn't, so tips are disabled for circle shape tool
- [x] tool pointer works for all tools (e.g. rectangle tool uses the pens pointer)
- [x] handle large pen sizes
  - +/- buttons, [/] shortcuts & slider round to: (text input can manually be set to anything)
    - 1-50: 1
    - 50-100: 5
    - 100-500: 10
    - 500+: 50

### phase 7.2: shape tools

- [x] shape tool: constraint to square/circle & 45,90,... deg lines when shift is pressed
- [x] shape tool: center around starting point when ctrl is pressed
- [x] rectangle & circle tool have a outline & fill toggle button
  - outline & fill toggle button are in shapes new 3rd column
  - outline uses primary color
  - fill uses secondary color
  - defaults: outline=on, fill=off
- [x] swap rectangle & arrow tool buttons
- [x] save boarder/fill values to recents/favorites

### phase 7.3: text tool

- [x] text tool: above selection tool in tools ribbon
- [x] options: (dropdown from tool)
  - size (not using pen size)
  - bold, italics, underline, strike through
- [x] using pen color
- [x] font: whatever the app uses, no config needed
- [x] transformations: until placed you can
  - move: drag box edge
  - rotate & mirror: selection buttons
- [x] optional border
- [x] shortcut: T
- [x] recents/favorites
  - icon: A icon with text color fill and outline color
  - trailing: circle icon with fill & outline rules matching shapes
  - text: {font size} px

### phase 7.4: colors

- [x] higher brightness range in 12x5 picker
- [x] color picker: better UI
  - lib: flutter_colorpicker or flutter_color_picker_plus (which ever works better)
  - variant: hue & alpha slider + rectangle value & saturation
  - maintain hex text input
  - maintain org v new color

### phase 7.5: selection

- [x] pasting inserts content centered
  - when cursor is in viewport, center around cursor
  - otherwise center in viewport
- [x] status bar size indicator shows selection and shape sizes when in those modes
  - xy values is the bounding box size (not including boarders) of the selection/shape
  - for constraint mode, use the shapes actual corner points
  - size display has constant width
- [x] arrow keys move selection
  - default: 1px in document space
  - modifier: shift: 10px in document space
- [x] remove paste to new layer:
  - position pasted content centered relative to selection (when content is too large or small)
  - when pasting into smaller selection, clip paste value to selection
- [x] multi frame selections:
  - film icon button in selection ribbon:
    - enabled on a per-frame layer
    - a toggle that switches between this-frame, and all frames mode
    - toggling commits any current selections
    - remember value between selections
  - any actions performed on selection, are performed in all frames
  - transformations, erasures, & clipboard actions are applied per frame using the respective frames pixels
  - copy, cut, & paste:
    - new app internal multi frame clipboard
    - internal clipboard stores images for all frames + which frame or image was visible
    - system clipboard receives one image from the current frame
    - detect external pastes overriding multi frame clips
      - on paste, compare the system clipboard & visible internal clipboard frame
      - if same, paste internal clipboard value on all frames
      - if different, paste system clipboard and clear internal clipboard
  - frame alignment: relative to selected frame (to allow temporal movements)
  - mismatched frame counts:
    - multi frame: ignore overflow, don't change underflow frames
    - single: paste to all frames
    - pasting multi frame in single mode: paste frame that was visible when copying
  - history items: each item hols the changes for all frames
  - switching frames with a selection active: 
    - keep all selections lifted
    - when copying & pasting, the currently active frame is the reference frame
- [x] multi frame selection modes:
  - mode button is split button
  - secondary action opens a popup
  - popup has toggle buttons to independently select forward and backward directions
  - only frames in the enabled directions will be included/affected

### phase 7.6: misc tool refinements

- [x] right-click tool/setting for auto reverting tool/setting selection:
  - when right clicking a tool or color, then the tool-config is temporary and after one use we switch back to the previous tool/setting preset
  - when right-click selecting another tool, settings can still be changed
  - revert once tool has been used
    - selection is done once there's no more selection
  - when reverting, settings are reverted too (using recent tool presets)
  - can right click all buttons that contribute to tool presets:
    - tools, shapes, colors, 
    - pen settings: size, tip
    - shape settings: boarder, fill
    - text settings: size, formatting, boarder, fill, border size
- [x] shortcut: tab to switch to next previous tool
  - selects next recent preset after current selection (regardless of wether it was used or not)
  - skip locked presets (skip to first recent preset)
  - scroll new selection into view
- [x] split favorite/locked and recent lists
  - separator between lists
  - both allow up to 9 items
  - 1-9 shortcut apply to favorites only
  - tab / shift+tab applies to recents only (I think this is already implemented)
  - change lock/unlock icons for solid & outline star
  - favorite button show number for secondary action when not hovered
- [x] re-add system cursor for tools

### phase 8: right pane refinement

### phase 8.1: ui feel

- [ ] history previews show entire picture, not just modified layer
  - how? save full image, recompute from all the diffs?
- [ ] bulk actions:
  - layers, frames, and history items are selectable
  - edit, move, delete actions are applied to the selection
- [ ] move image previews to left of layer, frames & history items?
- [ ] history & layer item preview enlarges on hover?
- [ ] or hovering over previews in layers, frames, and history switches the canvas to show just that layer, frame, or history

- [ ] right panel list item layout:
  - select checkbox?
  - drag handle
  - preview image
  - name
  - action buttons
- [ ] right list item actions:
  - layers: frame mode, visibility + opacity
  - frames: hold -#+
  - history: revert
- [ ] right panel actions:
  - layers: add, clone, merge, rename, delete
  - frames: add, clone, delete
  - history: layerize


### phase 8.2: layers

- [ ] merge down layers:
  - button between copy & merge
  - merges selected layer with layer below
- [ ] allow renaming layers

### phase 8.3: history

- [ ] delete/revert history items: append new history item that applies the reverse diff
  - how to handle erasure?
- [ ] convert history items into layer: append convert to layer at end of history that applies all required changes
  - how to treat deletions at start of selection? apply inversion bitmap in layer above?
  - can we layerize selective actions, or just from an action until end?
  - how about layer CRUD ops? disallow layerization?
  - what if i've gone back (undid) some items? drop residual items?
  - how to handle edits in per-frame layers
- [ ] revert/layerize should push new items, not actually remove/edit history (so that you can undo a history edit)

### phase 9: polish

### phase 9.1: performance

- [x] FPS on larger canvases
  - a 4096*4096 canvas is unusable
  - Layer image cache
  - Checkerboard improvements
  - Hover & tool preview move into own render layer
  - While drawing, only paint canvas
- [x] Hide system cursor
- [ ] separate threads for input capture & render
- [ ] check memory consumption & performance of history stack
- [ ] history stack memory management
  - [ ] stack limit
  - [ ] or progressive history item merging
  - [ ] image compression (package:archive, XOR against previous layer)
- [ ] drawing with huge tools, crashes app

### phase 9.2: image properties

- [x] allow resizing image:
  - size in status bar is a button
  - button triggers resize dialog
  - resize dialog: 
    - inputs for new size
    - inputs for offset (of old content in new canvas)
    - button (next to offset inputs) to center old image in new canvas (by setting offsets)
    - <=256 x <=256 px preview of new canvas (i.e. as large as can fit in 256x256)
- [x] crop tool:
  - in selection ribbon
  - enabled when a selection is made
  - crop layers & frames to selection
- [x] allow renaming documents stored in-app in editor
  - file name in status bar is a button
  - button triggers text input dialog (cannot save empty name)
  - name change stored in memory until document is saved
- [x] allow renaming documents stored in-app in new docs list
  - new doc tab docs list has rename icon button left of delete
  - button triggers text input dialog
  - saves immediately upon closing dialog

### phase 9.3: files & document

- [x] new docs tab: in-app docs have duplicate button
  - new doc tab docs list has duplicate button between rename & delete
  - increase saved doc list width by aprox 2 buttons
- [x] file open & save remember last location for doc (instead of default to code project)
- [x] editor canvas shows `Loading...` text in center until image is loaded
- [x] clicking the download primary button auto overrides a saved path, only secondary drop down options trigger path selection
- [x] new doc tabs open file file-picker defaults to last folder
  - approximate last opened folder by getting the path of the most recent doc

### phase 9.4: bugs

- [x] ctrl/cmd+scroll zooming not working on web
- [ ] right click on web triggers system context menu
- [ ] touch inputs both move canvas & draw
- [ ] stylus doesn't seem to work properly

### phase 9.53: misc

- [ ] text inputs with label use different label looks
- [ ] text inputs have unit text on right side
- [ ] pen ribbon becomes dynamic current tool settings ribbon
  - for pen & eraser: Pen ribbon
  - for text: Text ribbon - todo: text has lot's of settings taking up lots of space
  - for select: Selection ribbon: rotate, mirror, select all, crop
  - others: ?
  - constant width

### phase x: todo

- [ ] animation loop toggle
- [ ] interchangeable panes: move panes between top & right panels
- [ ] wide double buttons for pairs: undo/redo, rotate, mirror
- [ ] colors: add no-color option, no-color button below dialog button
- [ ] transparent colors: blend mode
- [ ] history slider

### phase y: vector graphics

- docs are either pixel or vector type
- support infinite zoom for recursive art
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

