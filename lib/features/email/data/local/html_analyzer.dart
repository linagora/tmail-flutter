
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/model.dart';

class HtmlAnalyzer {

  Future<EmailContent> transformEmailContent(EmailContent emailContent) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlTransform = HtmlTransform(emailContent.content);
        final htmlContent = htmlTransform.transformToHtml();
        return EmailContent(emailContent.type, htmlContent);
      default:
        return emailContent;
    }
  }
}