import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_number_of_unread_spam_emails_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_last_time_dismissed_spam_reported_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/store_spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_unread_spam_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_last_time_dismissed_spam_reported_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/store_spam_report_state_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class SpamReportController extends BaseController {
  final StoreSpamReportInteractor _storeSpamReportInteractor;
  final GetUnreadSpamMailboxInteractor _getNumberOfUnreadSpamEmailsInteractor;
  final StoreSpamReportStateInteractor _storeSpamReportStateInteractor;
  final GetSpamReportStateInteractor _getSpamReportStateInteractor;

  final _presentationSpamMailbox = Rxn<PresentationMailbox>();
  final _spamReportState = Rxn<SpamReportState>(SpamReportState.enabled);

  SpamReportController(
      this._storeSpamReportInteractor,
      this._getNumberOfUnreadSpamEmailsInteractor,
      this._storeSpamReportStateInteractor,
      this._getSpamReportStateInteractor);

  @override
  void onDone() {
     viewState.value.fold(
      (failure) {
        logError('SpamReportController::onDone(): failure: $failure');
      },
      (success) {
        if(success is GetUnreadSpamMailboxSuccess){
          _presentationSpamMailbox.value = success.unreadSpamMailbox.toPresentationMailbox();
          log('SpamReportController::GetNumberOfUnreadSpamEmailsSuccess():success $success');
        } else if (success is StoreLastTimeDismissedSpamReportSuccess) {
          _presentationSpamMailbox.value = null;
          log('SpamReportController::StoreLastTimeDismissedSpamReportSuccess():success $success');
        } else if (success is GetSpamReportStateSuccess) {
          _spamReportState.value = success.spamReportState;
          log('SpamReportController::GetSpamReportStateSuccess():success $success');
        } else if (success is StoreSpamReportStateSuccess) {
          _spamReportState.value = success.spamReportState;
          log('SpamReportController::StoreSpamReportStateSuccess():success $success');
        }
      },
    );
  }
  
  void dismissSpamReportAction() {
    _storeLastTimeDismissedSpamReportedAction();
  }

  void getUnreadSpamMailboxAction(AccountId accountId) {
    final _mailboxFilterCondition = MailboxFilterCondition(role: Role('Spam'));
    getSpamReportStateAction();
    consumeState(_getNumberOfUnreadSpamEmailsInteractor.execute(accountId,mailboxFilterCondition: _mailboxFilterCondition));
  }

  void _storeLastTimeDismissedSpamReportedAction() {
    consumeState(_storeSpamReportInteractor.execute(DateTime.now()));
  }

  bool get notShowSpamReportBanner => _presentationSpamMailbox.value == null;

  int get numberOfUnreadSpamEmails => (_presentationSpamMailbox.value?.unreadEmails?.value.value ?? 0).toInt();

  bool get enableSpamReport => _spamReportState.value == SpamReportState.enabled;

  void openMailbox(BuildContext context) {
    final _mailboxDashBoardController = Get.find<MailboxDashBoardController>();
    dismissSpamReportAction();
    _mailboxDashBoardController.openSpamMailboxAction(context, _presentationSpamMailbox.value!);
  }

  void storeSpamReportStateAction(SpamReportState spamReportState) {
   consumeState(_storeSpamReportStateInteractor.execute(spamReportState));
  }

  void getSpamReportStateAction() {
   consumeState(_getSpamReportStateInteractor.execute());
  }
}
