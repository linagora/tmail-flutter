
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/model.dart';

class EmailContent with EquatableMixin {

  final String content;
  final EmailContentType type;

  EmailContent(this.type, this.content);

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
  List<Object?> get props => [type, content];
}