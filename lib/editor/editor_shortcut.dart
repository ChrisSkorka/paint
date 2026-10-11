import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum ShortcutGroup {
  tabs(label: 'Tabs'),
  file(label: 'File'),
  selection(label: 'Selection'),
  tools(label: 'Tools'),
  colors(label: 'Colors'),
  view(label: 'View'),
  animation(label: 'Animation'),
  layers(label: 'Layers');

  const ShortcutGroup({required this.label});

  final String label;
}

enum EditorShortcut {
  newTab(
    label: 'New tab',
    group: ShortcutGroup.tabs,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyN,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  save(
    label: 'Save',
    group: ShortcutGroup.file,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyS,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  export(
    label: 'Export',
    group: ShortcutGroup.file,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyE,
        control: true,
        shift: true,
        includeRepeats: false,
      ),
    ],
  ),
  undo(
    label: 'Undo',
    group: ShortcutGroup.file,
    activators: [SingleActivator(LogicalKeyboardKey.keyZ, control: true)],
  ),
  redo(
    label: 'Redo',
    group: ShortcutGroup.file,
    activators: [
      SingleActivator(LogicalKeyboardKey.keyY, control: true),
      SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true),
    ],
  ),
  copy(
    label: 'Copy',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyC,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  cut(
    label: 'Cut',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyX,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  paste(
    label: 'Paste',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyV,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  selectAll(
    label: 'Select all',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyA,
        control: true,
        includeRepeats: false,
      ),
    ],
  ),
  deleteSelection(
    label: 'Delete selection',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(LogicalKeyboardKey.delete, includeRepeats: false),
      SingleActivator(LogicalKeyboardKey.backspace, includeRepeats: false),
    ],
  ),
  deselect(
    label: 'Deselect',
    group: ShortcutGroup.selection,
    activators: [
      SingleActivator(LogicalKeyboardKey.escape, includeRepeats: false),
    ],
  ),
  pen(
    label: 'Pen',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyP)],
  ),
  eraser(
    label: 'Eraser',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyE)],
  ),
  fill(
    label: 'Fill',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyG)],
  ),
  colorPicker(
    label: 'Color picker',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyI)],
  ),
  holdColorPicker(
    label: 'Color picker while held',
    group: ShortcutGroup.tools,
    activators: [],
    keysLabel: 'Alt',
  ),
  select(
    label: 'Select',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyM)],
  ),
  line(
    label: 'Line',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyL)],
  ),
  rectangle(
    label: 'Rectangle',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyR)],
  ),
  circle(
    label: 'Circle',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyO)],
  ),
  arrow(
    label: 'Arrow',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.keyA)],
  ),
  toolPreset(
    label: 'Recent / favorite tool',
    group: ShortcutGroup.tools,
    activators: [
      SingleActivator(LogicalKeyboardKey.digit1),
      SingleActivator(LogicalKeyboardKey.digit2),
      SingleActivator(LogicalKeyboardKey.digit3),
      SingleActivator(LogicalKeyboardKey.digit4),
      SingleActivator(LogicalKeyboardKey.digit5),
      SingleActivator(LogicalKeyboardKey.digit6),
      SingleActivator(LogicalKeyboardKey.digit7),
      SingleActivator(LogicalKeyboardKey.digit8),
      SingleActivator(LogicalKeyboardKey.digit9),
    ],
    keysLabel: '1–9',
  ),
  smallerSize(
    label: 'Smaller size',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.bracketLeft)],
  ),
  largerSize(
    label: 'Larger size',
    group: ShortcutGroup.tools,
    activators: [SingleActivator(LogicalKeyboardKey.bracketRight)],
  ),
  swapColors(
    label: 'Swap colors',
    group: ShortcutGroup.colors,
    activators: [
      SingleActivator(LogicalKeyboardKey.keyX, includeRepeats: false),
    ],
  ),
  zoomIn(
    label: 'Zoom in',
    group: ShortcutGroup.view,
    activators: [SingleActivator(LogicalKeyboardKey.equal, control: true)],
  ),
  zoomOut(
    label: 'Zoom out',
    group: ShortcutGroup.view,
    activators: [SingleActivator(LogicalKeyboardKey.minus, control: true)],
  ),
  resetZoom(
    label: 'Reset zoom',
    group: ShortcutGroup.view,
    activators: [SingleActivator(LogicalKeyboardKey.digit0, control: true)],
  ),
  previousFrame(
    label: 'Previous frame',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.comma)],
  ),
  nextFrame(
    label: 'Next frame',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.period)],
  ),
  firstFrame(
    label: 'First frame',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.home)],
  ),
  lastFrame(
    label: 'Last frame',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.end)],
  ),
  playPause(
    label: 'Play / pause',
    group: ShortcutGroup.animation,
    activators: [
      SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false),
    ],
  ),
  onionSkinning(
    label: 'Onion skinning',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.f3, includeRepeats: false)],
  ),
  addFrame(
    label: 'Add frame',
    group: ShortcutGroup.animation,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyN,
        alt: true,
        includeRepeats: false,
      ),
    ],
  ),
  copyFrame(
    label: 'Copy frame',
    group: ShortcutGroup.animation,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyD,
        alt: true,
        includeRepeats: false,
      ),
    ],
  ),
  removeFrame(
    label: 'Remove frame',
    group: ShortcutGroup.animation,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.delete,
        alt: true,
        includeRepeats: false,
      ),
    ],
  ),
  moveFrameUp(
    label: 'Move frame up',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.comma, alt: true)],
  ),
  moveFrameDown(
    label: 'Move frame down',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.period, alt: true)],
  ),
  fewerHolds(
    label: 'Fewer holds',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.minus, alt: true)],
  ),
  moreHolds(
    label: 'More holds',
    group: ShortcutGroup.animation,
    activators: [SingleActivator(LogicalKeyboardKey.equal, alt: true)],
  ),
  addLayer(
    label: 'Add layer',
    group: ShortcutGroup.layers,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyN,
        shift: true,
        includeRepeats: false,
      ),
    ],
  ),
  copyLayer(
    label: 'Copy layer',
    group: ShortcutGroup.layers,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.keyD,
        shift: true,
        includeRepeats: false,
      ),
    ],
  ),
  removeLayer(
    label: 'Remove layer',
    group: ShortcutGroup.layers,
    activators: [
      SingleActivator(
        LogicalKeyboardKey.delete,
        shift: true,
        includeRepeats: false,
      ),
    ],
  ),
  layerAbove(
    label: 'Layer above',
    group: ShortcutGroup.layers,
    activators: [SingleActivator(LogicalKeyboardKey.pageUp)],
  ),
  layerBelow(
    label: 'Layer below',
    group: ShortcutGroup.layers,
    activators: [SingleActivator(LogicalKeyboardKey.pageDown)],
  ),
  moveLayerUp(
    label: 'Move layer up',
    group: ShortcutGroup.layers,
    activators: [SingleActivator(LogicalKeyboardKey.pageUp, alt: true)],
  ),
  moveLayerDown(
    label: 'Move layer down',
    group: ShortcutGroup.layers,
    activators: [SingleActivator(LogicalKeyboardKey.pageDown, alt: true)],
  );

  const EditorShortcut({
    required this.label,
    required this.group,
    required this.activators,
    this.keysLabel,
  });

  final String label;
  final ShortcutGroup group;
  final List<SingleActivator> activators;
  final String? keysLabel;

  static final _keyNames = {
    LogicalKeyboardKey.delete: 'Del',
    LogicalKeyboardKey.escape: 'Esc',
    LogicalKeyboardKey.pageUp: 'PgUp',
    LogicalKeyboardKey.pageDown: 'PgDn',
  };

  String get keys => keysLabel ?? activators.map(describe).join(' / ');

  String tooltip(String text) => '$text ($keys)';

  static String describe(SingleActivator activator) => [
    if (activator.control) 'Ctrl',
    if (activator.shift) 'Shift',
    if (activator.alt) 'Alt',
    _keyNames[activator.trigger] ?? activator.trigger.keyLabel,
  ].join('+');

  int activatorIndex(KeyEvent event) => activators.indexWhere(
    (activator) => activator.accepts(event, HardwareKeyboard.instance),
  );

  static EditorShortcut? matching(KeyEvent event) => values.firstWhereOrNull(
    (shortcut) => shortcut.activatorIndex(event) >= 0,
  );
}
