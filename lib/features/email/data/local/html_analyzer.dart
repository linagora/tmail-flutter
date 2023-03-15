
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_tooltip_link_transformers.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/convert_url_string_to_html_links_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';

class HtmlAnalyzer {

  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String>? mapUrlDownloadCID,
    DioClient dioClient,
    {bool draftsEmail = false}
  ) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlTransform = HtmlTransform(
          emailContent.content,
          dioClient: dioClient,
          mapUrlDownloadCID: mapUrlDownloadCID
        );

        final htmlContent = await htmlTransform.transformToHtml(
          transformConfiguration: draftsEmail
            ? TransformConfiguration.create(customDomTransformers: TransformConfiguration.domTransformersForDraftEmail)
            : null
        );

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