
import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/text/convert_url_string_to_html_links_transformers.dart';
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
      case EmailContentType.textPlain:
        final htmlTransform = HtmlTransform(emailContent.content);
        final message = htmlTransform.transformToTextPlain(
            transformConfiguration: TransformConfiguration.create(
                customTextTransformers: [const ConvertUrlStringToHtmlLinksTransformers()]));
        return EmailContent(emailContent.type, message);
      default:
        return emailContent;
    }
  }

  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlTransform = HtmlTransform(emailContent.content);
        final htmlContent = await htmlTransform.transformToHtml(
            transformConfiguration: TransformConfiguration.create(
                customDomTransformers: [const AddTooltipLinkTransformer()]));
        return EmailContent(emailContent.type, htmlContent);
      default:
        return emailContent;
    }
  }
}