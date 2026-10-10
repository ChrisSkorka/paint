import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../editor/files/stored_document.dart';
import 'history_list.dart';
import 'paint_icon_button.dart';
import 'paint_style.dart';

class StoredDocumentList extends StatelessWidget {
  const StoredDocumentList({
    super.key,
    required this.documents,
    required this.onOpen,
    required this.onDelete,
  });

  static const thumbnailSize = 40.0;

  final List<StoredDocument> documents;
  final ValueChanged<StoredDocument> onOpen;
  final ValueChanged<StoredDocument> onDelete;

  static String formatModified(DateTime modified) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${modified.year}-${twoDigits(modified.month)}-'
        '${twoDigits(modified.day)} ${twoDigits(modified.hour)}:'
        '${twoDigits(modified.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Text(
        'No saved documents',
        style: TextStyle(color: PaintStyle.titleColor),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final document in documents)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onOpen(document),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  spacing: 8,
                  children: [
                    HistoryThumbnail(
                      thumbnail: document.thumbnail,
                      outline: null,
                      size: thumbnailSize,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(document.name, overflow: TextOverflow.ellipsis),
                          Text(
                            formatModified(document.modified),
                            style: const TextStyle(
                              color: PaintStyle.titleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PaintIconButton(
                      icon: FontAwesomeIcons.trashCan,
                      tooltip: 'Delete ${document.name}',
                      onPressed: () => onDelete(document),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
