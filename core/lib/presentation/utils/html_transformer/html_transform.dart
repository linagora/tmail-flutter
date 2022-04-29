import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';
import 'package:html/dom.dart';

class HtmlTransform {

  final String _contentHtml;
  Map<String, String>? mapUrlDownloadCID;
  DioClient? dioClient;

  HtmlTransform(
    this._contentHtml,
    {
      this.mapUrlDownloadCID,
      this.dioClient,
    }
  );

  /// Transforms this message to HTML code.
  Future<String> transformToHtml({TransformConfiguration? transformConfiguration}) async {
    final document = await transformToDocument(transformConfiguration: transformConfiguration);
    return document.outerHtml;
  }

  /// Transforms this message to Document.
  Future<Document> transformToDocument({TransformConfiguration? transformConfiguration}) async {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration);
    return await transformer.toDocument(_contentHtml, mapUrlDownloadCID: mapUrlDownloadCID, dioClient: dioClient);
  }
}