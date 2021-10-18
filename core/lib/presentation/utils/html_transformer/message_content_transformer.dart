import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The configuration used for the transformation
  final TransformConfiguration configuration;
  final DioClient dioClient;

  MessageContentTransformer(this.configuration, this.dioClient);

  Future<void> transformDocument(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
  ) async {
    await Future.wait(configuration.domTransformers.map((domTransformer) async {
      await domTransformer.process(document, message, mapUrlDownloadCID, configuration, dioClient);
    }));
  }

  Future<Document> toDocument(String message, Map<String, String>? mapUrlDownloadCID) async {
    var html = message;
    final document = parse(html);
    await transformDocument(document, message, mapUrlDownloadCID);
    return document;
  }
}