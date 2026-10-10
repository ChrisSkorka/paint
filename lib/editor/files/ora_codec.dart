import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../canvas/document.dart';
import '../canvas/document_layer.dart';
import '../canvas/layer.dart';
import '../canvas/pixel_color.dart';
import '../canvas/pixel_point.dart';
import 'document_format_exception.dart';
import 'image_codec.dart';

abstract final class OraCodec {
  static const mimeType = 'image/openraster';
  static const thumbnailSize = 256;
  static const stackPath = 'stack.xml';
  static const mergedImagePath = 'mergedimage.png';
  static const thumbnailPath = 'Thumbnails/thumbnail.png';

  static Uint8List encode({required Document document}) {
    final merged = document.flatten(background: PixelColor.transparent);
    final archive = Archive()
      ..add(
        ArchiveFile.noCompress(
          'mimetype',
          mimeType.length,
          utf8.encode(mimeType),
        ),
      )
      ..add(
        ArchiveFile.bytes(
          stackPath,
          utf8.encode(_stackXml(document: document)),
        ),
      )
      ..add(
        ArchiveFile.bytes(mergedImagePath, ImageCodec.encodePng(layer: merged)),
      )
      ..add(
        ArchiveFile.bytes(
          thumbnailPath,
          ImageCodec.encodePng(
            layer: Layer.thumbnail(layer: merged, maximumSize: thumbnailSize),
          ),
        ),
      );
    for (var index = 0; index < document.layers.length; index++) {
      archive.add(
        ArchiveFile.bytes(
          _layerPath(index: index),
          ImageCodec.encodePng(layer: document.layers[index].pixels),
        ),
      );
    }
    return ZipEncoder().encodeBytes(archive);
  }

  static Document decode({required String name, required Uint8List bytes}) {
    try {
      return _decode(name: name, bytes: bytes);
    } on FormatException {
      throw DocumentFormatException.unsupported();
    }
  }

  static String _layerPath({required int index}) => 'data/layer$index.png';

  static String _stackXml({required Document document}) {
    final builder = XmlBuilder()..declaration(encoding: 'UTF-8');
    builder.element(
      'image',
      attributes: {
        'version': '0.0.5',
        'w': '${document.width}',
        'h': '${document.height}',
      },
      nest: () => builder.element(
        'stack',
        nest: () {
          for (var index = document.layers.length - 1; index >= 0; index--) {
            final layer = document.layers[index];
            builder.element(
              'layer',
              attributes: {
                'name': layer.name,
                'src': _layerPath(index: index),
                'x': '0',
                'y': '0',
                'visibility': layer.visible ? 'visible' : 'hidden',
                'opacity': (layer.opacity / DocumentLayer.maximumOpacity)
                    .toStringAsFixed(2),
                if (index == document.activeLayerIndex) 'selected': 'true',
              },
            );
          }
        },
      ),
    );
    return builder.buildDocument().toXmlString(pretty: true);
  }

  static Document _decode({required String name, required Uint8List bytes}) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final stack = archive.findFile(stackPath)?.readBytes();
    if (stack == null) throw DocumentFormatException.unsupported();
    final image = XmlDocument.parse(utf8.decode(stack)).rootElement;
    final width = int.tryParse(image.getAttribute('w') ?? '') ?? 0;
    final height = int.tryParse(image.getAttribute('h') ?? '') ?? 0;
    if (width < Document.minimumSize || height < Document.minimumSize) {
      throw DocumentFormatException.unsupported();
    }
    DocumentFormatException.checkSize(width: width, height: height);
    final elements = image.findAllElements('layer').toList().reversed.toList();
    if (elements.isEmpty) throw DocumentFormatException.unsupported();
    return Document(
      name: name,
      width: width,
      height: height,
      layers: [
        for (var index = 0; index < elements.length; index++)
          _decodeLayer(
            archive: archive,
            element: elements[index],
            index: index,
            width: width,
            height: height,
          ),
      ],
      activeLayerIndex: _selectedIndex(elements: elements),
    );
  }

  static DocumentLayer _decodeLayer({
    required Archive archive,
    required XmlElement element,
    required int index,
    required int width,
    required int height,
  }) {
    final source = archive
        .findFile(element.getAttribute('src') ?? '')
        ?.readBytes();
    final image = source == null ? null : ImageCodec.decode(bytes: source);
    if (image == null) throw DocumentFormatException.unsupported();
    final pixels =
        Layer.filled(
          width: width,
          height: height,
          color: PixelColor.transparent,
        )..paste(
          source: image,
          at: PixelPoint(
            x: int.tryParse(element.getAttribute('x') ?? '') ?? 0,
            y: int.tryParse(element.getAttribute('y') ?? '') ?? 0,
          ),
        );
    final opacity = double.tryParse(element.getAttribute('opacity') ?? '') ?? 1;
    return DocumentLayer(
      name: element.getAttribute('name') ?? 'Layer ${index + 1}',
      pixels: pixels,
      visible: element.getAttribute('visibility') != 'hidden',
      opacity: (opacity * DocumentLayer.maximumOpacity).round().clamp(
        DocumentLayer.minimumOpacity,
        DocumentLayer.maximumOpacity,
      ),
    );
  }

  static int _selectedIndex({required List<XmlElement> elements}) {
    final selected = elements.indexWhere(
      (element) => element.getAttribute('selected') == 'true',
    );
    return selected == -1 ? elements.length - 1 : selected;
  }
}
