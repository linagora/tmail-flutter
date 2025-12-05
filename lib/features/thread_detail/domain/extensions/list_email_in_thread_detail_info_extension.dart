import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension
    on List<EmailInThreadDetailInfo> {
  List<EmailId> emailIdsToDisplay(bool isSentMailbox) => isSentMailbox
      ? map((email) => email.emailId).toList()
      : where((email) => email.isValidToDisplay)
          .map((email) => email.emailId)
          .toList();

  List<EmailInThreadDetailInfo> starAll() {
    return map((email) {
      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> unstarAll() {
    return map((email) {
      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> starByEmailIds(List<EmailId> targetIds) {
    final targetSet = targetIds.toSet();

    return map((email) {
      if (!targetSet.contains(email.emailId)) return email;

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> unstarByEmailIds(List<EmailId> targetIds) {
    final targetSet = targetIds.toSet();

    return map((email) {
      if (!targetSet.contains(email.emailId)) return email;

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> starOne(EmailId emailId) {
    return map((email) {
      if (email.emailId != emailId) {
        return email;
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..[KeyWordIdentifier.emailFlagged] = true;

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }

  List<EmailInThreadDetailInfo> unstarOne(EmailId emailId) {
    return map((email) {
      if (email.emailId != emailId) {
        return email;
      }

      final updatedKeywords = Map<KeyWordIdentifier, bool>.from(
        email.keywords ?? {},
      )..remove(KeyWordIdentifier.emailFlagged);

      return email.copyWith(keywords: updatedKeywords);
    }).toList();
  }
}
