import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../editor/canvas/document.dart';
import '../../editor/editor_shortcut.dart';
import '../../editor/files/document_library.dart';
import '../../editor/files/file_access.dart';
import '../../editor/files/image_clipboard.dart';
import '../components/document_tab_bar.dart';
import 'editor_view.dart';
import 'new_document_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.clipboard,
    required this.files,
    required this.library,
  });

  final ImageClipboard clipboard;
  final FileAccess files;
  final DocumentLibrary library;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final tabs = [_OpenTab(key: UniqueKey())];
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (ModalRoute.isCurrentOf(context) == false ||
        EditorShortcut.matching(event) != EditorShortcut.newTab) {
      return false;
    }
    _addTab();
    return true;
  }

  void _addTab() => setState(() {
    tabs.add(_OpenTab(key: UniqueKey()));
    selectedIndex = tabs.length - 1;
  });

  void _selectTab(int index) => setState(() => selectedIndex = index);

  void _openDocument({required _OpenTab tab, required Document document}) =>
      setState(() => tab.document = document);

  void _markUnsaved({required _OpenTab tab, required bool unsaved}) =>
      setState(() => tab.unsaved = unsaved);

  Future<void> _closeTab(int index) async {
    final tab = tabs[index];
    if (tab.unsaved && !await _confirmClose(name: tab.title)) return;
    setState(() {
      tabs.remove(tab);
      if (tabs.isEmpty) tabs.add(_OpenTab(key: UniqueKey()));
      if (index < selectedIndex) selectedIndex--;
      selectedIndex = min(selectedIndex, tabs.length - 1);
    });
  }

  Future<bool> _confirmClose({required String name}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close $name?'),
        content: const Text('Unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close without saving'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PrimaryScrollController.none(
        child: Column(
          children: [
            DocumentTabBar(
              tabs: [
                for (final tab in tabs)
                  (title: tab.title, unsaved: tab.unsaved),
              ],
              selectedIndex: selectedIndex,
              onSelect: _selectTab,
              onClose: _closeTab,
              onAdd: _addTab,
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  for (final (index, tab) in tabs.indexed)
                    KeyedSubtree(
                      key: tab.key,
                      child: _buildTab(
                        tab: tab,
                        active: index == selectedIndex,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required _OpenTab tab, required bool active}) {
    final document = tab.document;
    if (document == null) {
      return NewDocumentView(
        clipboard: widget.clipboard,
        files: widget.files,
        library: widget.library,
        onCreate: (document) => _openDocument(tab: tab, document: document),
      );
    }
    return EditorView(
      document: document,
      clipboard: widget.clipboard,
      files: widget.files,
      library: widget.library,
      active: active,
      onUnsavedChanged: (unsaved) => _markUnsaved(tab: tab, unsaved: unsaved),
    );
  }
}

class _OpenTab {
  _OpenTab({required this.key});

  static const newTitle = 'New document';

  final Key key;
  Document? document;
  var unsaved = false;

  String get title => document?.name ?? newTitle;
}
