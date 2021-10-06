import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Transforms messages
class MessageContentTransformer {
  /// The configuration used for the transformation
  final TransformConfiguration configuration;

  MessageContentTransformer(this.configuration);

  void transformDocument(Document document, String message) {
    for (final domTransformer in configuration.domTransformers) {
      domTransformer.process(document, message, configuration);
    }
  }

  Document toDocument(String message) {
    var html = message;
    final document = parse(html);
    transformDocument(document, message);
    return document;
  }

  String toHtml(String message) {
    return toDocument(message).outerHtml;
  }
}