import 'package:core/core.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The configuration used for the transformation
  final TransformConfiguration configuration;

  MessageContentTransformer(this.configuration);

  Future<void> _transformDocument(
      Document document,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    await Future.wait([
      if (configuration.domTransformers.isNotEmpty)
        ...configuration.domTransformers.map((domTransformer) async =>
            domTransformer.process(
                document,
                mapUrlDownloadCID: mapUrlDownloadCID,
                dioClient: dioClient))
    ]);
  }

  Future<Document> toDocument(
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final document = parse(message);
    await _transformDocument(
        document,
        mapUrlDownloadCID: mapUrlDownloadCID,
        dioClient: dioClient);
    return document;
  }

  String _transformMessage(String message) {
    if (configuration.textTransformers.isNotEmpty) {
      configuration.textTransformers.forEach((transformer) {
        message = transformer.process(message);
      });
    }
    return message;
  }

  String toMessage(String message) {
    return _transformMessage(message);
  }
}