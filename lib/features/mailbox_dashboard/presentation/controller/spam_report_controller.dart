import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_mailbox_cached_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_last_time_dismissed_spam_reported_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_mailbox_cached_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_last_time_dismissed_spam_reported_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class SpamReportController extends BaseController {
  final StoreSpamReportInteractor _storeSpamReportInteractor;
  final StoreSpamReportStateInteractor _storeSpamReportStateInteractor;
  final GetSpamReportStateInteractor _getSpamReportStateInteractor;
  final GetSpamMailboxCachedInteractor _getSpamMailboxCachedInteractor;

  final presentationSpamMailbox = Rxn<PresentationMailbox>();
  final spamReportState = Rx<SpamReportState>(SpamReportState.enabled);

  SpamReportController(
    this._storeSpamReportInteractor,
    this._storeSpamReportStateInteractor,
    this._getSpamReportStateInteractor,
    this._getSpamMailboxCachedInteractor
  );

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is StoreLastTimeDismissedSpamReportSuccess) {
      presentationSpamMailbox.value = null;
    } else if (success is GetSpamReportStateSuccess) {
      spamReportState.value = success.spamReportState;
    } else if (success is StoreSpamReportStateSuccess) {
      spamReportState.value = success.spamReportState;
    } else if (success is GetSpamMailboxCachedSuccess) {
      presentationSpamMailbox.value = success.spamMailbox.toPresentationMailbox();
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetSpamMailboxCachedFailure) {
      presentationSpamMailbox.value = null;
    }
  }

  void dismissSpamReportAction(BuildContext context) {
    if (Get.isRegistered<MailboxDashBoardController>()) {
      final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
      final spamMailbox = presentationSpamMailbox.value;
      final session = mailboxDashBoardController.sessionCurrent;
      final accountId = mailboxDashBoardController.accountId.value;

      if (spamMailbox != null && session != null && accountId != null) {
        _storeLastTimeDismissedSpamReportedAction();

        mailboxDashBoardController.markAsReadMailbox(
          session,
          accountId,
          spamMailbox.id,
          spamMailbox.getDisplayName(context),
          spamMailbox.countUnreadEmails
        );
        presentationSpamMailbox.value = null;
      }
    }
  }

  void getSpamMailboxCached(AccountId accountId, UserName userName) {
    consumeState(_getSpamMailboxCachedInteractor.execute(accountId, userName));
  }

  void _storeLastTimeDismissedSpamReportedAction() {
    consumeState(_storeSpamReportInteractor.execute(DateTime.now()));
  }

  String get numberOfUnreadSpamEmails => presentationSpamMailbox.value?.countUnReadEmailsAsString ?? '';

  bool get enableSpamReport => spamReportState.value == SpamReportState.enabled;

  void openMailbox() {
    final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    _storeLastTimeDismissedSpamReportedAction();
    mailboxDashBoardController.openMailboxAction(presentationSpamMailbox.value!);
  }

  void storeSpamReportStateAction(SpamReportState spamReportState) {
   consumeState(_storeSpamReportStateInteractor.execute(spamReportState));
  }

  void getSpamReportStateAction() {
    consumeState(_getSpamReportStateInteractor.execute());
  }

  void setSpamPresentationMailbox(PresentationMailbox? spamMailbox) {
    presentationSpamMailbox.value = spamMailbox;
  }
}
