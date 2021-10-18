import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/dom.dart';

class HtmlTransform {

  final String _contentHtml;
  Map<String, String>? mapUrlDownloadCID;
  DioClient dioClient;

  HtmlTransform(
    this._contentHtml,
    this.dioClient,
    this.mapUrlDownloadCID
  );

  /// Transforms this message to HTML code.
  /// Optionally specify the [transformConfiguration] to control all aspects of the transformation
  /// - in that case other parameters are ignored.
  Future<String> transformToHtml({TransformConfiguration? transformConfiguration}) async {
    final document = await transformToDocument(transformConfiguration: transformConfiguration);
    return document.outerHtml;
  }

  /// Transforms this message to Document.
  Future<Document> transformToDocument({TransformConfiguration? transformConfiguration}) async {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration, dioClient);
    return await transformer.toDocument(_contentHtml, mapUrlDownloadCID);
  }
}