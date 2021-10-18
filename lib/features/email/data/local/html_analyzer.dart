
import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/model.dart';

class HtmlAnalyzer {

  Future<EmailContent> transformEmailContent(
      EmailContent emailContent,
      Map<String, String>? mapUrlDownloadCID,
      DioClient dioClient
  ) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlTransform = HtmlTransform(
            emailContent.content,
            dioClient,
            mapUrlDownloadCID);
        final htmlContent = await htmlTransform.transformToHtml();
        return EmailContent(emailContent.type, htmlContent);
      default:
        return emailContent;
    }
  }
}