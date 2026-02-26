import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';

extension HandleLogicLabelExtension on MailboxDashBoardController {
  bool get isLabelCapabilitySupported {
    final accountId = this.accountId.value;
    final session = sessionCurrent;

    if (accountId == null || session == null) return false;

    return labelController.isLabelCapabilitySupported(session, accountId);
  }

  bool get isLabelAvailable {
    return labelController.isLabelSettingEnabled.isTrue &&
        isLabelCapabilitySupported;
  }

  void syncListLabelForListEmail(
    List<EmailId> emailIds,
    List<KeyWordIdentifier> labelKeywords,
    {bool shouldRemove = false}
  ) {
    _syncLabelsForEmailList(emailIds, labelKeywords, shouldRemove);
    _refreshLabelSettingEnabled();
  }

  void _syncLabelsForEmailList(
    List<EmailId> emailIds,
    List<KeyWordIdentifier> labelKeywords,
    bool shouldRemove,
  ) {
    updateEmailFlagByEmailIds(
      emailIds,
      labelKeywords: labelKeywords,
      isLabelAdded: !shouldRemove,
    );
  }

  void _refreshLabelSettingEnabled() {
    labelController.isLabelSettingEnabled.refresh();
  }
}
