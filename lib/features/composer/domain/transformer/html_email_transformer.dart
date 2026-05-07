import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';

abstract class HtmlEmailTransformer {
  Future<String> transformToHtml({
    required String htmlContent,
    required TransformConfiguration transformConfiguration,
    Map<String, String>? mapCidImageDownloadUrl,
  });
}
