import 'package:flutter/material.dart';

import '../../editor/canvas/document.dart';
import '../components/paint_style.dart';
import 'editor_view.dart';
import 'new_document_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));
  Document? document;

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void _openDocument(Document document) {
    setState(() => this.document = document);
    tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final document = this.document;
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: PaintStyle.barBackground,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: PaintStyle.iconColor,
                unselectedLabelColor: PaintStyle.titleColor,
                indicatorColor: PaintStyle.colorPickerColor,
                dividerColor: PaintStyle.separatorColor,
                labelStyle: const TextStyle(
                  fontFamily: PaintStyle.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(height: 32, text: 'New document'),
                  Tab(height: 32, text: 'Editor'),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: tabController.index,
              children: [
                NewDocumentView(onCreate: _openDocument),
                document == null
                    ? const Center(child: Text('No document open'))
                    : EditorView(key: ObjectKey(document), document: document),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
