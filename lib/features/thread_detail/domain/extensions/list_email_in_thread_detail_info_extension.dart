import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension on List<EmailInThreadDetailInfo> {
  List<EmailId> emailIdsToDisplay(bool isSentMailbox) => isSentMailbox
      ? map((email) => email.emailId).toList()
      : where((email) => email.isValidToDisplay)
          .map((email) => email.emailId)
          .toList();

  List<EmailInThreadDetailInfo> toggleEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    return map((emailInfo) {
      if (emailInfo.emailId != emailId) {
        return emailInfo;
      }
      return emailInfo.toggleKeyword(keyword, remove);
    }).toList();
  }
}