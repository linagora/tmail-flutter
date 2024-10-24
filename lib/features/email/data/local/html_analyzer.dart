import 'package:collection/collection.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/parser.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

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
          transformConfiguration: TransformConfiguration.fromTextTransformers([
            const SanitizeAutolinkHtmlTransformers()
          ]),
        );
        return EmailContent(emailContent.type, message);
      default:
        return emailContent;
    }
  }

  Future<List<EventAction>> getListEventAction(String emailContents) async {
    try {
      final document = parse(emailContents);

      final openPaasLinkElements = document.querySelectorAll('a.part-button');
      if (openPaasLinkElements.isNotEmpty) {
        final listEventAction = openPaasLinkElements
          .mapIndexed((index, element) {
            final hrefLink = element.attributes['href'] ?? '';
            if (hrefLink.isNotEmpty) {
              if (index == 0) {
                return EventAction(EventActionType.yes, hrefLink);
              } else if (index == 1) {
                return EventAction(EventActionType.maybe, hrefLink);
              } else if (index == 2) {
                return EventAction(EventActionType.no, hrefLink);
              }
            }
            return null;
          })
          .whereNotNull()
          .toList();
        log('HtmlAnalyzer::getListEventAction:OPEN_PAAS::listEventAction: $listEventAction');
        return listEventAction;
      } else {
        final googleLinkElements = document.querySelectorAll('a.grey-button-text');
        final listEventAction = googleLinkElements
          .mapIndexed((index, element) {
            final hrefLink = element.attributes['href'] ?? '';
            if (hrefLink.isNotEmpty) {
              if (index == 0) {
                return EventAction(EventActionType.yes, hrefLink);
              } else if (index == 1) {
                return EventAction(EventActionType.no, hrefLink);
              } else if (index == 2) {
                return EventAction(EventActionType.maybe, hrefLink);
              }
            }
            return null;
          })
          .whereNotNull()
          .toList();
        log('HtmlAnalyzer::getListEventAction:GOOGLE::listEventAction: $listEventAction');
        return listEventAction;
      }
    } catch(e) {
      logError('HtmlAnalyzer::getListEventAction:Exception: $e');
      return [];
    }
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