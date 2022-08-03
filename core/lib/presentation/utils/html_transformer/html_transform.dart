import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';

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
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration);
    final document = await transformer.toDocument(
        _contentHtml,
        mapUrlDownloadCID: mapUrlDownloadCID,
        dioClient: dioClient);
    return document.outerHtml;
  }

  /// Transforms this message to Text Plain.
  String transformToTextPlain({TransformConfiguration? transformConfiguration}) {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration);
    final message = transformer.toMessage(_contentHtml);
    return message;
  }
}