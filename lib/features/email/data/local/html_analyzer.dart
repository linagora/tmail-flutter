import 'package:collection/collection.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/parser.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';

class HtmlAnalyzer {

  final HtmlTransform _htmlTransform;

  HtmlAnalyzer(this._htmlTransform);

  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String> mapCidImageDownloadUrl,
    TransformConfiguration transformConfiguration
  ) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlContent = await _htmlTransform.transformToHtml(
          htmlContent: emailContent.content,
          mapCidImageDownloadUrl: mapCidImageDownloadUrl,
          transformConfiguration: transformConfiguration
        );

        return EmailContent(emailContent.type, htmlContent);
      case EmailContentType.textPlain:
        final message = _htmlTransform.transformToTextPlain(
          content: emailContent.content,
          transformConfiguration: transformConfiguration
        );
        return EmailContent(emailContent.type, message);
      default:
        return emailContent;
    }
  }

  Future<List<String>> getListLinkCalendarEvent(String emailContents) async {
    final document = parse(emailContents);
    final linkElements = document.querySelectorAll('a.part-button');
    final listLink = linkElements
      .map((element) => element.attributes['href'])
      .whereNotNull()
      .toList();
    return listLink;
  }

  Future<String> transformHtmlEmailContent(
    String htmlContent,
    TransformConfiguration configuration
  ) async {
    final htmlContentTransformed = await _htmlTransform.transformToHtml(
      htmlContent: htmlContent,
      transformConfiguration: configuration
    );
    return htmlContentTransformed;
  }
}