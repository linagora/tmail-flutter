
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_tooltip_link_transformers.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:html/parser.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';

class HtmlAnalyzer {

  final HtmlTransform _htmlTransform;
  final HtmlEscape _htmlEscape;

  HtmlAnalyzer(this._htmlTransform, this._htmlEscape);

  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String>? mapUrlDownloadCID,
    {bool draftsEmail = false}
  ) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlContent = await _htmlTransform.transformToHtml(
          contentHtml: emailContent.content,
          mapUrlDownloadCID: mapUrlDownloadCID,
          transformConfiguration: draftsEmail
            ? TransformConfiguration.create(customDomTransformers: TransformConfiguration.domTransformersForDraftEmail)
            : null
        );

        return EmailContent(emailContent.type, htmlContent);
      case EmailContentType.textPlain:
        final message = _htmlTransform.transformToTextPlain(
          content: emailContent.content,
          transformConfiguration: TransformConfiguration.create(
            customTextTransformers: [SanitizeAutolinkHtmlTransformers(_htmlEscape)]
          )
        );
        return EmailContent(emailContent.type, message);
      default:
        return emailContent;
    }
  }

  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) async {
    switch(emailContent.type) {
      case EmailContentType.textHtml:
        final htmlContent = await _htmlTransform.transformToHtml(
          contentHtml: emailContent.content,
          transformConfiguration: TransformConfiguration.create(
            customDomTransformers: [const AddTooltipLinkTransformer()]
          )
        );
        return EmailContent(emailContent.type, htmlContent);
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
}