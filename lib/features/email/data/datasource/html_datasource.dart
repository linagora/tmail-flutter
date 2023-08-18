
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:model/model.dart';

abstract class HtmlDataSource {
  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String> mapCidImageDownloadUrl,
    TransformConfiguration transformConfiguration
  );

  Future<String> transformHtmlEmailContent(
    String htmlContent,
    TransformConfiguration configuration
  );
}