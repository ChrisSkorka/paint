import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../canvas/document.dart';
import '../canvas/document_layer.dart';
import '../canvas/frame_timing.dart';
import '../canvas/layer.dart';
import '../canvas/layer_timeframe.dart';
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
  static const paintNamespace = 'urn:info.skorka.chris.paint';
  static const paintPrefix = 'paint';
  static const fpsAttribute = 'fps';
  static const frameHoldsAttribute = 'frame-holds';
  static const legacyFrameDurationsAttribute = 'frame-durations';
  static const timeframeAttribute = 'timeframe';
  static const perFrameTimeframe = 'per-frame';

  static Uint8List encode({required Document document}) {
    final merged = document.flatten(
      background: PixelColor.transparent,
      frame: 0,
    );
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
      final layer = document.layers[index];
      for (var frame = 0; frame < layer.images.length; frame++) {
        archive.add(
          ArchiveFile.bytes(
            _layerPath(layer: layer, index: index, frame: frame),
            ImageCodec.encodePng(layer: layer.images[frame]),
          ),
        );
      }
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

  static String _layerPath({
    required DocumentLayer layer,
    required int index,
    required int frame,
  }) => switch (layer.timeframe) {
    LayerTimeframe.constant => 'data/layer$index.png',
    LayerTimeframe.perFrame => 'data/layer$index-frame$frame.png',
  };

  static String _opacityText(int opacity) =>
      (opacity / DocumentLayer.maximumOpacity).toStringAsFixed(2);

  static String _stackXml({required Document document}) {
    final builder = XmlBuilder()..declaration(encoding: 'UTF-8');
    builder.element(
      'image',
      namespaceUris: {paintPrefix: paintNamespace},
      attributes: {
        'version': '0.0.5',
        'w': '${document.width}',
        'h': '${document.height}',
      },
      nest: () {
        builder
          ..attribute(
            fpsAttribute,
            '${document.fps}',
            namespaceUri: paintNamespace,
          )
          ..attribute(
            frameHoldsAttribute,
            document.frameHolds.join(','),
            namespaceUri: paintNamespace,
          )
          ..element(
            'stack',
            nest: () {
              for (
                var index = document.layers.length - 1;
                index >= 0;
                index--
              ) {
                _buildLayer(builder: builder, document: document, index: index);
              }
            },
          );
      },
    );
    return builder.buildDocument().toXmlString(pretty: true);
  }

  static void _buildLayer({
    required XmlBuilder builder,
    required Document document,
    required int index,
  }) {
    final layer = document.layers[index];
    final attributes = {
      'visibility': layer.visible ? 'visible' : 'hidden',
      'opacity': _opacityText(layer.opacity),
      if (index == document.activeLayerIndex) 'selected': 'true',
    };
    switch (layer.timeframe) {
      case LayerTimeframe.constant:
        builder.element(
          'layer',
          attributes: {
            'name': layer.name,
            'src': _layerPath(layer: layer, index: index, frame: 0),
            'x': '0',
            'y': '0',
            ...attributes,
          },
        );
      case LayerTimeframe.perFrame:
        builder.element(
          'stack',
          attributes: {'name': layer.name, ...attributes},
          nest: () {
            builder.attribute(
              timeframeAttribute,
              perFrameTimeframe,
              namespaceUri: paintNamespace,
            );
            for (var frame = 0; frame < layer.images.length; frame++) {
              builder.element(
                'layer',
                attributes: {
                  'name': '${layer.name} ${frame + 1}',
                  'src': _layerPath(layer: layer, index: index, frame: frame),
                  'x': '0',
                  'y': '0',
                  'visibility': frame == 0 ? 'visible' : 'hidden',
                  'opacity': _opacityText(DocumentLayer.maximumOpacity),
                },
              );
            }
          },
        );
    }
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
    final timing = _frameTiming(image: image);
    final rootStack = image.getElement('stack');
    final elements = rootStack == null
        ? <XmlElement>[]
        : _layerElements(stack: rootStack).reversed.toList();
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
            frameCount: timing.holds.length,
          ),
      ],
      activeLayerIndex: _selectedIndex(elements: elements),
      frameHolds: timing.holds,
      fps: timing.fps,
    );
  }

  static FrameTiming _frameTiming({required XmlElement image}) {
    String? attribute(String name) =>
        image.getAttribute(name, namespaceUri: paintNamespace);
    final holds = attribute(frameHoldsAttribute);
    if (holds != null) {
      final values = holds.split(',');
      return FrameTiming(
        fps:
            (int.tryParse(attribute(fpsAttribute) ?? '') ?? Document.defaultFps)
                .clamp(Document.minimumFps, Document.maximumFps),
        holds: [
          for (var frame = 0; frame < values.length; frame++)
            (int.tryParse(values[frame].trim()) ?? 1).clamp(
              Document.minimumHolds(frame: frame),
              Document.maximumHolds,
            ),
        ],
      );
    }
    final durations = attribute(legacyFrameDurationsAttribute);
    if (durations == null) {
      return const FrameTiming(fps: Document.defaultFps, holds: [1]);
    }
    return FrameTiming.fromDurations(
      centiseconds: [
        for (final duration in durations.split(','))
          ((int.tryParse(duration.trim()) ?? 0) /
                  FrameTiming.millisecondsPerCentisecond)
              .round(),
      ],
    );
  }

  static bool _isFrameStack(XmlElement element) =>
      element.name.local == 'stack' &&
      element.getAttribute(timeframeAttribute, namespaceUri: paintNamespace) ==
          perFrameTimeframe;

  static List<XmlElement> _layerElements({required XmlElement stack}) => [
    for (final child in stack.childElements)
      if (child.name.local == 'layer' || _isFrameStack(child))
        child
      else if (child.name.local == 'stack')
        ..._layerElements(stack: child),
  ];

  static DocumentLayer _decodeLayer({
    required Archive archive,
    required XmlElement element,
    required int index,
    required int width,
    required int height,
    required int frameCount,
  }) {
    final opacity = double.tryParse(element.getAttribute('opacity') ?? '') ?? 1;
    final frameStack = _isFrameStack(element);
    final frames = element.childElements
        .where((child) => child.name.local == 'layer')
        .toList();
    return DocumentLayer(
      name: element.getAttribute('name') ?? 'Layer ${index + 1}',
      images: frameStack
          ? [
              for (var frame = 0; frame < frameCount; frame++)
                frame < frames.length
                    ? _decodeImage(
                        archive: archive,
                        element: frames[frame],
                        width: width,
                        height: height,
                      )
                    : Layer.filled(
                        width: width,
                        height: height,
                        color: PixelColor.transparent,
                      ),
            ]
          : [
              _decodeImage(
                archive: archive,
                element: element,
                width: width,
                height: height,
              ),
            ],
      timeframe: frameStack ? LayerTimeframe.perFrame : LayerTimeframe.constant,
      visible: element.getAttribute('visibility') != 'hidden',
      opacity: (opacity * DocumentLayer.maximumOpacity).round().clamp(
        DocumentLayer.minimumOpacity,
        DocumentLayer.maximumOpacity,
      ),
    );
  }

  static Layer _decodeImage({
    required Archive archive,
    required XmlElement element,
    required int width,
    required int height,
  }) {
    final source = archive
        .findFile(element.getAttribute('src') ?? '')
        ?.readBytes();
    final image = source == null ? null : ImageCodec.decode(bytes: source);
    if (image == null) throw DocumentFormatException.unsupported();
    return Layer.filled(
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
  }

  static int _selectedIndex({required List<XmlElement> elements}) {
    final selected = elements.indexWhere(
      (element) => element.getAttribute('selected') == 'true',
    );
    return selected == -1 ? elements.length - 1 : selected;
  }
}
