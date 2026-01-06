import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension
    on List<EmailInThreadDetailInfo> {
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

  List<EmailInThreadDetailInfo> toggleListEmailsKeywordByIds({
    required List<EmailId> emailIds,
    required KeyWordIdentifier keyword,
    required bool remove,
  }) {
    final targetIds = emailIds.toSet();

    return map((emailInfo) {
      if (!targetIds.contains(emailInfo.emailId)) {
        return emailInfo;
      }

      return emailInfo.toggleKeyword(keyword, remove);
    }).toList();
  }

  List<Label> findCommonLabelsInThread({
    required List<Label> labels,
  }) {
    if (isEmpty || labels.isEmpty) return const [];

    final iterator = where((e) => e.isValidToDisplay).iterator;
    if (!iterator.moveNext()) return const [];

    // Initialize with the first valid email
    var commonKeywords = iterator.current.keywords.enabledKeywordSet;

    if (commonKeywords.isEmpty) return const [];

    // Intersect with remaining emails
    while (iterator.moveNext()) {
      commonKeywords = commonKeywords.intersection(
        iterator.current.keywords.enabledKeywordSet,
      );

      if (commonKeywords.isEmpty) return const [];
    }

    return labels
        .where((label) =>
            label.keyword != null && commonKeywords.contains(label.keyword))
        .toList();
  }
}
