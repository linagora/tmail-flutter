import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_emails_by_ids_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadDetailController extends BaseController {
  final GetThreadByIdInteractor _getEmailIdsByThreadIdInteractor;
  final GetEmailsByIdsInteractor getEmailsByIdsInteractor;

  ThreadDetailController(
    this._getEmailIdsByThreadIdInteractor,
    this.getEmailsByIdsInteractor,
  );

  final emailIds = <EmailId>[].obs;
  final emailIdsPresentation = <EmailId, PresentationEmail?>{}.obs;

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final searchEmailController = Get.find<SearchEmailController>();

  AccountId? get accountId => mailboxDashBoardController.accountId.value;
  Session? get session => mailboxDashBoardController.sessionCurrent;
  MailboxId? get sentMailboxId => mailboxDashBoardController.getMailboxIdByRole(
    PresentationMailbox.roleSent,
  );
  String? get ownEmailAddress => session?.getOwnEmailAddress();
  int get emailsNotLoadedCount => emailIdsPresentation
    .values
    .where((email) => email == null)
    .length;
  bool get loadingThreadDetail => viewState.value.fold(
    (failure) => false,
    (success) => success is GettingThreadById
      || success is GettingEmailsByIds,
  );
  bool get isSearchRunning {
    final isWebSearchRunning = mailboxDashBoardController
      .searchController
      .isSearchEmailRunning;
    final isMobileSearchRunning = searchEmailController
      .searchIsRunning
      .value == true;
    return isWebSearchRunning || isMobileSearchRunning;
  }

  @override
  void onInit() {
    super.onInit();
    ever(mailboxDashBoardController.selectedEmail, (presentationEmail) {
      if (presentationEmail?.threadId == null) {
        closeThreadDetailAction(currentContext);
        return;
      }
      if (session != null &&
          accountId != null &&
          sentMailboxId != null &&
          ownEmailAddress != null) {
        consumeState(_getEmailIdsByThreadIdInteractor.execute(
          presentationEmail!.threadId!,
          session!,
          accountId!,
          sentMailboxId!,
          ownEmailAddress!,
        ));
      }
    });
  }

  void reset() {
    emailIds.clear();
    emailIdsPresentation.clear();
  }

  @override
  void handleSuccessViewState(success) {
    if (success is GetThreadByIdSuccess) {
      handleGetEmailIdsByThreadIdSuccess(success);
      initializeThreadDetailEmails();
    } else if (success is GetEmailsByIdsSuccess) {
      handleGetEmailsByIdsSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(failure) {
    if (failure is GetThreadByIdFailure) {
      showRetryToast(failure);
      return;
    }
    if (failure is GetEmailsByIdsFailure) {
      showRetryToast(failure);
      return;
    }
    super.handleFailureViewState(failure);
  }
}