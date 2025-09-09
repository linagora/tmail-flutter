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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/loader_status.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SpamReportController extends BaseController {
  final StoreSpamReportInteractor _storeSpamReportInteractor;
  final StoreSpamReportStateInteractor _storeSpamReportStateInteractor;
  final GetSpamReportStateInteractor _getSpamReportStateInteractor;
  final GetSpamMailboxCachedInteractor _getSpamMailboxCachedInteractor;

  final presentationSpamMailbox = Rxn<PresentationMailbox>();
  final spamReportState = Rx<SpamReportState>(SpamReportState.enabled);

  AppLifecycleListener? _appLifecycleListener;
  LoaderStatus _spamReportLoaderStatus = LoaderStatus.idle;

  SpamReportController(
    this._storeSpamReportInteractor,
    this._storeSpamReportStateInteractor,
    this._getSpamReportStateInteractor,
    this._getSpamMailboxCachedInteractor
  );

  @override
  void onInit() {
    super.onInit();
    _appLifecycleListener ??= AppLifecycleListener(
      onResume: () {
        if (_spamReportLoaderStatus == LoaderStatus.loading) {
          return;
        }
        getSpamReportStateAction();
      },
    );
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is StoreLastTimeDismissedSpamReportSuccess) {
      presentationSpamMailbox.value = null;
    } else if (success is GetSpamReportStateLoading) {
      _spamReportLoaderStatus = LoaderStatus.loading;
    } else if (success is GetSpamReportStateSuccess) {
      _loadSpamReportConfigSuccess(success.spamReportState);
    } else if (success is StoreSpamReportStateSuccess) {
      spamReportState.value = success.spamReportState;
      getBinding<MailboxDashBoardController>()?.refreshSpamReportBanner();
    } else if (success is GetSpamMailboxCachedSuccess) {
      presentationSpamMailbox.value = success.spamMailbox.toPresentationMailbox();
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetSpamMailboxCachedFailure) {
      presentationSpamMailbox.value = null;
    } else if (failure is GetSpamReportStateFailure) {
      _spamReportLoaderStatus = LoaderStatus.completed;
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    _spamReportLoaderStatus = LoaderStatus.completed;
  }

  void _loadSpamReportConfigSuccess(SpamReportState newState) {
    spamReportState.value = newState;
    _spamReportLoaderStatus = LoaderStatus.completed;
    getBinding<MailboxDashBoardController>()?.refreshSpamReportBanner();
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
          spamMailbox.unreadEmails?.value.value.toInt() ?? 0
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

  @override
  void onClose() {
    _appLifecycleListener?.dispose();
    super.onClose();
  }
}
