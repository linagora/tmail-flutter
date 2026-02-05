import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';

extension HandleLogicLabelExtension on MailboxDashBoardController  {
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

  void syncLabelForEmail(
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
    bool shouldRemove,
  ) {
    _syncLabelForEmailList(emailId, labelKeyword, shouldRemove);
    _refreshLabelSettingEnabled();

    if (isEmailOpened) {
      dispatchEmailUIAction(
        SyncUpdateLabelForEmailOnMemory(
          emailId: emailId,
          labelKeyword: labelKeyword,
          shouldRemove: shouldRemove,
        ),
      );
    }
  }

  void _syncLabelForEmailList(
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
    bool shouldRemove,
  ) {
    updateEmailFlagByEmailIds(
      [emailId],
      isLabelAdded: !shouldRemove,
      labelKeyword: labelKeyword,
    );
  }

  void _refreshLabelSettingEnabled() {
    labelController.isLabelSettingEnabled.refresh();
  }
}
