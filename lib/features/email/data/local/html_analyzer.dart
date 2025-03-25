
import 'package:collection/collection.dart';
import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/persist_preformatted_text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_html_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/string_convert.dart';
import 'package:dartz/dartz.dart';
import 'package:html/parser.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:uuid/uuid.dart';

class HtmlAnalyzer {
  static const String cidPrefixKey = 'cid:';

  final HtmlTransform _htmlTransform;
  final FileUploader _fileUploader;
  final Uuid _uuid;

  HtmlAnalyzer(this._htmlTransform, this._fileUploader, this._uuid);

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
            const SanitizeAutolinkHtmlTransformers(),
            const PersistPreformattedTextTransformer(),
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
          .nonNulls
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
          .nonNulls
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
    required Map<String, Attachment> inlineAttachments,
    required Uri? uploadUri,
  }) async {
    final document = parse(emailContent);
    final listImgTag = document.querySelectorAll('img[src^="data:image/"]');

    log('HtmlAnalyzer::replaceImageBase64ToImageCID:listImgTagLength = ${listImgTag.length} | inlineAttachments = ${inlineAttachments.length}');

    if (listImgTag.isEmpty) {
      return Tuple2(
        emailContent,
        inlineAttachments.isNotEmpty
          ? inlineAttachments.values.toList().toEmailBodyPart(charset: Constant.base64Charset)
          : {},
      );
    }

    final Set<EmailBodyPart> inlineAttachmentsSet = {};

    for (final imgTag in listImgTag) {
      final attributes = imgTag.attributes;
      final imageSrc = attributes['src'];
      if (imageSrc?.isEmpty ?? true) continue;

      final idImg = attributes['id'];
      if (idImg?.startsWith(cidPrefixKey) == true) {
        final cid = idImg!.substring(cidPrefixKey.length).trim();
        final attachment = inlineAttachments[cid];

        if (attachment != null) {
          attributes['src'] = '$cidPrefixKey$cid';
          attributes.remove('id');
          inlineAttachmentsSet.add(attachment.toEmailBodyPart(charset: Constant.base64Charset));
          continue;
        }
      }

      if (uploadUri == null) continue;

      final taskId = idImg?.startsWith(cidPrefixKey) == true
        ? idImg!.substring(cidPrefixKey.length)
        : _uuid.v1();

      final attachmentRecord = await _retrieveAttachmentFromUpload(
        taskId: taskId,
        uploadUri: uploadUri,
        base64ImageTag: imageSrc!,
      );

      if (attachmentRecord == null) continue;

      final newInlineAttachment = attachmentRecord.$1.toAttachmentWithDisposition(
        disposition: ContentDisposition.inline,
        cid: attachmentRecord.$2,
      );

      final newCid = newInlineAttachment.cid!;
      inlineAttachments[newCid] = newInlineAttachment;
      attributes['src'] = '$cidPrefixKey$newCid';
      attributes.remove('id');

      inlineAttachmentsSet.add(newInlineAttachment.toEmailBodyPart(charset: Constant.base64Charset));
    }

    return Tuple2(document.body?.innerHtml ?? emailContent, inlineAttachmentsSet);
  }

  Future<String> removeCollapsedExpandedSignatureEffect({required String emailContent}) async {
    try {
      final document = parse(emailContent);
      final signatureElements = document.querySelectorAll('div.tmail-signature');
      await Future.wait(signatureElements.map((signatureTag) async {
        final signatureChildren = signatureTag.children;
        for (var child in signatureChildren) {
          if (child.attributes['class']?.contains('tmail-signature-button') == true) {
            child.remove();
          } else if (child.attributes['class']?.contains('tmail-signature-content') == true) {
            signatureTag.innerHtml = child.innerHtml;
          }
        }
      }));
      return document.body?.innerHtml ?? emailContent;
    } catch (e) {
      logError('HtmlAnalyzer::removeCollapsedExpandedSignatureEffect:Exception = $e');
      return emailContent;
    }
  }

  Future<(Attachment attachment, String taskId)?> _retrieveAttachmentFromUpload({
    required String taskId,
    required Uri uploadUri,
    required String base64ImageTag,
  }) async {
    try {
      final imageBytes = StringConvert.convertBase64ImageTagToBytes(base64ImageTag);
      final mediaType = StringConvert.getMediaTypeFromBase64ImageTag(base64ImageTag);
      log('HtmlAnalyzer::_retrieveAttachmentFromUpload: mimeType = ${mediaType?.mimeType} | imageBytesLength = ${imageBytes.length}');
      final fileInfo = FileInfo.fromBytes(
        bytes: imageBytes,
        name: '$taskId.${mediaType?.subtype ?? 'png'}',
        type: mediaType?.mimeType,
      );

      final attachment = await _fileUploader.uploadAttachment(
        UploadTaskId(taskId),
        fileInfo,
        uploadUri,
      );
      log('HtmlAnalyzer::_retrieveAttachmentFromUpload:Attachment = $attachment | taskId = $taskId');
      return (attachment, taskId);
    } catch (e) {
      logError('HtmlAnalyzer::_retrieveAttachmentFromUpload:Exception = $e');
      return null;
    }
  }

  Future<String> removeStyleLazyLoadDisplayInlineImages({required String emailContent}) async {
    try {
      final document = parse(emailContent);
      final imgElements = document.querySelectorAll('img[style], img[loading]');
      await Future.wait(imgElements.map((img) async {
        String? style = img.attributes['style'];
        if (style != null) {
          style = style.replaceAll(RegExp(r'display\s*:\s*inline;?'), '').trim();
          if (style.isEmpty) {
            img.attributes.remove('style');
          } else {
            img.attributes['style'] = style;
          }
        }

        if (img.attributes['loading'] == 'lazy') {
          img.attributes.remove('loading');
        }
      }));
      return document.body?.innerHtml ?? emailContent;
    } catch (e) {
      logError('HtmlAnalyzer::removeStyleLazyLoadDisplayInlineImages:Exception = $e');
      return emailContent;
    }
  }
}