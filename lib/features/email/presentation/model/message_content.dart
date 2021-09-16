
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/presentation/model/text_format.dart';
import 'package:model/model.dart';

class MessageContent with EquatableMixin {

  final TextFormat textFormat;
  final String content;

  MessageContent(this.textFormat, this.content);

  bool hasImageInlineWithCid() => content.contains('cid:');

  String getContentHasInlineAttachment(String baseDownloadUrl, AccountId accountId, List<Attachment> attachments) {
    var contentValid = content;
    attachments.forEach((attachment) {
      if(attachment.cid != null) {
        final urlDownloadImage = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        contentValid = content.replaceAll('cid:${attachment.cid}', '$urlDownloadImage');
      }
    });
    return contentValid;
  }

  @override
  List<Object?> get props => [textFormat, content];
}