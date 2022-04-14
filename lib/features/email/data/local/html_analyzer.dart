
import 'package:core/core.dart';
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
            dioClient: dioClient,
            mapUrlDownloadCID: mapUrlDownloadCID);
        final htmlContent = await htmlTransform.transformToHtml();
        return EmailContent(emailContent.type, htmlContent);
      default:
        return emailContent;
    }
  }

  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlTransform = HtmlTransform(emailContent.content);
        final htmlContent = await htmlTransform.transformToHtml(
            transformConfiguration: TransformConfiguration.create(customDomTransformers: [AddTooltipLinkTransformer()]));
        return EmailContent(emailContent.type, htmlContent);
      default:
        return emailContent;
    }
  }
}