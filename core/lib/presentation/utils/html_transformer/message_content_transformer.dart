import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The configuration used for the transformation
  final TransformConfiguration configuration;
  final DioClient dioClient;

  MessageContentTransformer(this.configuration, this.dioClient);

  Future<void> _transformDocument({
    required Document document,
    Map<String, String>? mapUrlDownloadCID
  }) async {
    await Future.wait([
      if (configuration.domTransformers.isNotEmpty)
        ...configuration.domTransformers.map((domTransformer) async =>
            domTransformer.process(
              document: document,
              mapUrlDownloadCID: mapUrlDownloadCID,
              dioClient: dioClient
            )
        )
    ]);
  }

  Future<Document> toDocument({
    required String message,
    Map<String, String>? mapUrlDownloadCID
  }) async {
    final document = parse(message);
    await _transformDocument(
      document: document,
      mapUrlDownloadCID: mapUrlDownloadCID,
    );
    return document;
  }

  String _transformMessage(String message) {
    if (configuration.textTransformers.isNotEmpty) {
      for (var transformer in configuration.textTransformers) {
        message = transformer.process(message);
      }
    }
    return message;
  }

  String toMessage(String message) {
    return _transformMessage(message);
  }
}