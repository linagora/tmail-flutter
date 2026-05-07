import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:tmail_ui_user/features/composer/domain/transformer/html_email_transformer.dart';

class HtmlEmailTransformerAdapter implements HtmlEmailTransformer {
  final HtmlTransform _htmlTransform;

  HtmlEmailTransformerAdapter(this._htmlTransform);

  @override
  Future<String> transformToHtml({
    required String htmlContent,
    required TransformConfiguration transformConfiguration,
    Map<String, String>? mapCidImageDownloadUrl,
  }) {
    return _htmlTransform.transformToHtml(
      htmlContent: htmlContent,
      transformConfiguration: transformConfiguration,
      mapCidImageDownloadUrl: mapCidImageDownloadUrl,
    );
  }
}
