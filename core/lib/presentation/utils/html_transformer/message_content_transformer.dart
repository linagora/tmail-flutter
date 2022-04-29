import 'package:core/core.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The configuration used for the transformation
  final TransformConfiguration configuration;

  MessageContentTransformer(this.configuration);

  Future<void> transformDocument(
      Document document,
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    await Future.wait([
      if (configuration.domTransformers.isNotEmpty) ...configuration.domTransformers.map((domTransformer) async =>
          domTransformer.process(document, message, mapUrlDownloadCID: mapUrlDownloadCID, dioClient: dioClient)),
      if (configuration.textTransformers.isNotEmpty) ...configuration.textTransformers.map((textTransformer) async =>
          textTransformer.process(message))
    ]);
  }

  Future<Document> toDocument(String message, {Map<String, String>? mapUrlDownloadCID, DioClient? dioClient}) async {
    var html = message;
    final document = parse(html);
    await transformDocument(document, message, mapUrlDownloadCID: mapUrlDownloadCID, dioClient: dioClient);
    return document;
  }
}