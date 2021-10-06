import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class HtmlTransform {

  final String _message;

  HtmlTransform(this._message);

  /// Transforms this message to HTML code.
  ///
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  String transformToHtml({
    bool? blockExternalImages,
    TransformConfiguration? transformConfiguration,
  }) {
    final document = transformToDocument(
      blockExternalImages: blockExternalImages,
      transformConfiguration: transformConfiguration,
    );
    return document.outerHtml;
  }

  /// Transforms this message to Document.
  ///
  /// Set [blockExternalImages] to `true` in case external images should be blocked.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation - in that case other parameters are ignored.
  Document transformToDocument({
    bool? blockExternalImages,
    int? maxImageWidth,
    TransformConfiguration? transformConfiguration,
  }) {
    transformConfiguration ??= TransformConfiguration.create(
      blockExternalImages: blockExternalImages,
      maxImageWidth: maxImageWidth,
    );
    final transformer = MessageContentTransformer(transformConfiguration);
    return transformer.toDocument(_message);
  }
}