import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/message_content_transformer.dart';

class HtmlTransform {

  final DioClient _dioClient;

  HtmlTransform(this._dioClient);

  /// Transforms this message to HTML code.
  Future<String> transformToHtml({
    required String contentHtml,
    Map<String, String>? mapUrlDownloadCID,
    TransformConfiguration? transformConfiguration,
  }) async {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration, _dioClient);
    final document = await transformer.toDocument(
      message: contentHtml,
      mapUrlDownloadCID: mapUrlDownloadCID
    );
    return document.outerHtml;
  }

  /// Transforms this message to Text Plain.
  String transformToTextPlain({
    required String content,
    TransformConfiguration? transformConfiguration
  }) {
    transformConfiguration ??= TransformConfiguration.create();
    final transformer = MessageContentTransformer(transformConfiguration, _dioClient);
    final message = transformer.toMessage(content);
    return message;
  }
}