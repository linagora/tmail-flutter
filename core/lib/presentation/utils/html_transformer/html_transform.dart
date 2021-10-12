import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class HtmlTransform {

  final String _contentHtml;

  HtmlTransform(this._contentHtml);

  /// Transforms this message to HTML code.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation
  /// - in that case other parameters are ignored.
  String transformToHtml({TransformConfiguration? transformConfiguration}) {
    final document = transformToDocument(transformConfiguration: transformConfiguration);
    return document.outerHtml;
  }

  /// Transforms this message to Document.
  Document transformToDocument({TransformConfiguration? transformConfiguration}) {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration);
    return transformer.toDocument(_contentHtml);
  }
}