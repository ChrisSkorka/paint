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
    - create new (pick size in pixels)
    - create from clipboard
    - open from shared_preferences
  - editor
    - top panel: MS Paint style panes
      - file
        - save & download
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
- support image types: jpg, png, gif
- saving
  - start from & save to real files
  - save to shared_preferences

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

- [ ] decode & encode png & jpg (`image` package), flatten visible layers on export
- [ ] open from real file (new document tab), save & download to real file (file pane)
- [ ] save to & open from shared_preferences (document list in new document tab)
- [ ] unsaved changes indicator

### phase 5: animations

- [ ] document frames & frame duration in model
- [ ] layer timeframe mode: constant (shown in every frame) or image per frame
- [ ] timeline in bottom panel: play / pause button, frame slider, add / remove frame
- [ ] gif import (frames → image-per-frame layer) & export
- [ ] save animations to shared_preferences

### phase 6: polish

### phase 6.1: performance

- [ ] check memory consumption & performance of history stack
  - a 4096*4096 canvas is unusable
- [ ] history stack memory management
  - [ ] stack limit
  - [ ] or progressive history item merging
  - [ ] image compression (package:archive, XOR against previous layer)

### phase 6.2: editor

- [ ] keyboard shortcuts for tools
- [ ] scrollable views always show scroll bars (& scroll bars are thick)
- [ ] scroll image to the right & bottom
- [ ] interchangeable panes: move panes between top & right panels
- [ ] tabs: multiple documents
- [ ] wide double buttons for pairs: undo/redo, rotate, mirror

### phase 6.3: improve tools

- [ ] pen ribbon: split size & tip into own ribbon, pen, eraser, and shapes use same settings, transparency mode for transparent color & selections
- [ ] shape tool: constraint to square/level when ctrl is pressed
- [ ] shape tool: fill with secondary color
- [ ] colors: add no-color option, no-color button below dialog button
- [ ] color picker: better UI
- [ ] transparent colors: blend mode

### phase 6.4: history

- [ ] history & layer item preview enlarges on hover
- [ ] history slider
- [ ] feature to convert history diff into layer

### phase 6.5: misc

- [ ] allow zoom less than 1x
- [ ] allow change image size
- [ ] move layer & history image previews to left
- [ ] allow renaming layers
- [ ] text inputs have unit text on right side
- [ ] ctrl + z/y no longer working
