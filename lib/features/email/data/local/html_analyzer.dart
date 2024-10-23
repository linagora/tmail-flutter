import 'package:collection/collection.dart';
import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:html/parser.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/extensions/attachment_extension.dart';
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

  Future<Tuple2<String, Set<EmailBodyPart>>> replaceImageBase64ToImageCID({
    required String emailContent,
    required Map<String, Attachment> inlineAttachments
  }) async {
    final document = parse(emailContent);
    final listImgTag = document.querySelectorAll('img[src^="data:image/"][id^="cid:"]');

    final listInlineAttachment = await Future.wait(listImgTag.map((imgTag) async {
      final idImg = imgTag.attributes['id'];
      final cid = idImg!.replaceFirst('cid:', '').trim();
      imgTag.attributes['src'] = 'cid:$cid';
      imgTag.attributes.remove('id');
      return cid;
    })).then((listCid) {
      final listInlineAttachment = listCid
        .map((cid) {
          if (inlineAttachments.containsKey(cid)) {
            return inlineAttachments[cid]!.toEmailBodyPart(charset: Constant.base64Charset);
          } else {
            return null;
          }
        })
        .whereNotNull()
        .toSet();

      return listInlineAttachment;
    });

    final newContent = document.body?.innerHtml ?? emailContent;

    return Tuple2(newContent, listInlineAttachment);
  }

  Future<String> removeCollapsedExpandedSignatureEffect({required String emailContent}) async {
    log('HtmlAnalyzer::removeCollapsedExpandedSignatureEffect: BEFORE = $emailContent');
    final document = parse(emailContent);
    final signatureElements = document.querySelectorAll('div.tmail-signature');
    await Future.wait(signatureElements.map((signatureTag) async {
      final signatureChildren = signatureTag.children;
      for (var child in signatureChildren) {
        log('HtmlAnalyzer::removeCollapsedExpandedSignatureEffect: CHILD = ${child.outerHtml}');
        if (child.attributes['class']?.contains('tmail-signature-button') == true) {
          child.remove();
        } else if (child.attributes['class']?.contains('tmail-signature-content') == true) {
          signatureTag.innerHtml = child.innerHtml;
        }
      }
    }));
    final newContent = document.body?.innerHtml ?? emailContent;
    log('HtmlAnalyzer::removeCollapsedExpandedSignatureEffect: AFTER = $newContent');
    return newContent;
  }
}