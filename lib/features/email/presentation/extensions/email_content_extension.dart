import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:tmail_ui_user/features/email/presentation/constants/email_constants.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';

extension EmailContentExtension on EmailContent {

  List<MessageContent> getListMessageContent() {
    Map<PartId, TextFormat> mapHtmlBody = Map();
    List<MessageContent> listMessageContent = [];

    htmlBody?.forEach((element) {
      if (element.partId != null && element.type != null) {
        mapHtmlBody[element.partId!] = element.type!.mimeType == EmailConstants.HTML_TEXT
          ? TextFormat.HTML
          : TextFormat.PLAIN;
      }
    });

    bodyValues?.forEach((key, value) {
      listMessageContent.add(MessageContent(mapHtmlBody[key] ?? TextFormat.PLAIN, value.value));
    });

    return listMessageContent;
  }

  List<Attachment> getListAttachment() {
    if (attachments != null) {
      return attachments!
        .where((element) => (element.disposition != null && element.disposition != 'inline'))
        .map((item) => item.toAttachment())
        .toList();
    }
    return [];
  }

  List<Attachment> getListAttachmentInline() {
    if (attachments != null) {
      return attachments!
          .where((element) => element.disposition == 'inline')
          .map((item) => item.toAttachment())
          .toList();
    }
    return [];
  }
}