import 'dart:collection';

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
    final List<Future<void>> asyncTasks = [];

    for (final imgTag in listImgTag) {
      late final LinkedHashMap<Object, String> attributes = imgTag.attributes;
      final idImg = attributes['id'];
      final imageSrc = attributes['src'];

      if (imageSrc?.isEmpty ?? true) continue;

      if (idImg?.startsWith(cidPrefixKey) == true) {
        final cid = idImg!.substring(cidPrefixKey.length).trim();
        attributes['src'] = '$cidPrefixKey$cid';
        attributes.remove('id');

        final attachment = inlineAttachments[cid];
        log('HtmlAnalyzer::replaceImageBase64ToImageCID:attachment = $attachment');
        if (attachment != null) {
          inlineAttachmentsSet.add(attachment.toEmailBodyPart(charset: Constant.base64Charset));
        }
        continue;
      }

      if (uploadUri == null) continue;

      asyncTasks.add(_retrieveAttachmentFromUpload(
        uploadUri: uploadUri,
        base64ImageTag: imageSrc!,
      ).then((newAttachment) {
        if (newAttachment == null) return;

        final newInlineAttachment = newAttachment.toAttachmentWithDisposition(
          disposition: ContentDisposition.inline,
          cid: _uuid.v1(),
        );
        final newCid = newInlineAttachment.cid;
        inlineAttachments[newCid!] = newInlineAttachment;
        attributes['src'] = '$cidPrefixKey$newCid';

        inlineAttachmentsSet.add(newInlineAttachment.toEmailBodyPart(charset: Constant.base64Charset));
      }));
    }

    if (asyncTasks.isNotEmpty) {
      await Future.wait(asyncTasks);
    }

    final newContent = document.body?.innerHtml ?? emailContent;
    return Tuple2(newContent, inlineAttachmentsSet);
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

  Future<Attachment?> _retrieveAttachmentFromUpload({
    required Uri uploadUri,
    required String base64ImageTag,
  }) async {
    try {
      final imageBytes = StringConvert.convertBase64ImageTagToBytes(base64ImageTag);
      final mediaType = StringConvert.getMediaTypeFromBase64ImageTag(base64ImageTag);
      log('HtmlAnalyzer::_retrieveAttachmentFromUpload: mimeType = ${mediaType?.mimeType} | imageBytesLength = ${imageBytes.length}');
      final generateId = _uuid.v1();
      final fileInfo = FileInfo.fromBytes(
        bytes: imageBytes,
        name: '$generateId.${mediaType?.subtype ?? 'png'}',
        type: mediaType?.mimeType,
      );

      final attachment = await _fileUploader.uploadAttachment(
        UploadTaskId(generateId),
        fileInfo,
        uploadUri,
      );
      log('HtmlAnalyzer::_retrieveAttachmentFromUpload:Attachment = $attachment');
      return attachment;
    } catch (e) {
      logError('HtmlAnalyzer::_retrieveAttachmentFromUpload:Exception = $e');
      return null;
    }
  }
}