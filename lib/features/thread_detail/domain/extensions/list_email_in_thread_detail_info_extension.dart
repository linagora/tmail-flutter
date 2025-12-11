import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension on List<EmailInThreadDetailInfo> {
  List<EmailId> emailIdsToDisplay(bool isSentMailbox) => isSentMailbox
      ? map((email) => email.emailId).toList()
      : where((email) => email.isValidToDisplay)
          .map((email) => email.emailId)
          .toList();

  List<EmailInThreadDetailInfo> addEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    return map((email) {
      if (email.emailId != emailId) {
        return email;
      }
      final newKeywords = email.keywords.withKeyword(keyword);
      return email.copyWith(keywords: newKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> removeEmailKeywordById({
    required EmailId emailId,
    required KeyWordIdentifier keyword,
  }) {
    return map((email) {
      if (email.emailId != emailId) {
        return email;
      }
      final newKeywords = email.keywords.withoutKeyword(keyword);
      return email.copyWith(keywords: newKeywords);
    }).toList();
  }
}