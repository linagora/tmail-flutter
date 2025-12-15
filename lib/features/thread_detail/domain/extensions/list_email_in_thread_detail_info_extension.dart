import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension
    on List<EmailInThreadDetailInfo> {
  List<EmailId> emailIdsToDisplay(bool isSentMailbox) => isSentMailbox
      ? map((emailInfo) => emailInfo.emailId).toList()
      : where((emailInfo) => emailInfo.isValidToDisplay)
          .map((emailInfo) => emailInfo.emailId)
          .toList();

  List<EmailInThreadDetailInfo> toggleEmailKeywords({
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    return map((emailInfo) => emailInfo.toggleKeyword(
          keyword: keyword,
          remove: remove,
        )).toList();
  }

  List<EmailInThreadDetailInfo> toggleEmailKeywordByIds({
    required List<EmailId> targetIds,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    if (targetIds.isEmpty) return this;

    final targetSet = targetIds.toSet();
    return map((emailInfo) {
      if (!targetSet.contains(emailInfo.emailId)) return emailInfo;
      return emailInfo.toggleKeyword(keyword: keyword, remove: remove);
    }).toList();
  }

  List<EmailInThreadDetailInfo> toggleEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    return map((emailInfo) {
      if (emailInfo.emailId != emailId) {
        return emailInfo;
      }
      return emailInfo.toggleKeyword(keyword: keyword, remove: remove);
    }).toList();
  }
}
