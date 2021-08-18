
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';
import 'package:model/model.dart';

class MessageContent with EquatableMixin {

  final TextFormat textFormat;
  final String content;

  MessageContent(this.textFormat, this.content);

  bool hasImageInlineWithCid() => content.contains('cid:');

  String getContentHasInlineAttachment(Session session, AccountId accountId, List<AttachmentFile> attachmentFiles) {
    var contentValid = content;
    attachmentFiles.forEach((attachment) {
      if(attachment.cid != null) {
        final urlDownloadImage = session.getDownloadUrl(
            '${accountId.id.value}',
            '${attachment.blobId?.value}',
            '${attachment.name}',
            '${attachment.type?.mimeType}');

        contentValid = content.replaceAll('cid:${attachment.cid}', '$urlDownloadImage');
      }
    });
    return contentValid;
  }

  @override
  List<Object?> get props => [textFormat, content];
}