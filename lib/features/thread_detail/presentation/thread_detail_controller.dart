import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_email_ids_by_thread_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/thread_detail_arguments.dart';

class ThreadDetailController extends BaseController {
  final ThreadDetailArguments arguments;
  final GetEmailIdsByThreadIdInteractor _getEmailIdsByThreadIdInteractor;
  final GetEmailsByIdsInteractor getEmailsByIdsInteractor;

  ThreadDetailController(
    this.arguments,
    this._getEmailIdsByThreadIdInteractor,
    this.getEmailsByIdsInteractor,
  );

  final emailIds = <EmailId>[].obs;
  final emailIdsPresentation = <EmailId, PresentationEmail?>{}.obs;
  final emailIdsStatus = <EmailId, EmailInThreadStatus>{}.obs;

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  AccountId? get accountId => mailboxDashBoardController.accountId.value;
  Session? get session => mailboxDashBoardController.sessionCurrent;

  @override
  void onInit() {
    super.onInit();
    if (accountId != null) {
      consumeState(_getEmailIdsByThreadIdInteractor.execute(
        arguments.threadId,
        accountId!,
      ));
    }
  }

  @override
  void handleSuccessViewState(success) {
    if (success is GetEmailIdsByThreadIdSuccess) {
      handleGetEmailIdsByThreadIdSuccess(success);
      initializeThreadDetailEmails();
    } else if (success is GetEmailsByIdsSuccess) {
      for (var presentationEmail in success.presentationEmails) {
        if (presentationEmail.id == null) continue;
        emailIdsPresentation[presentationEmail.id!] = presentationEmail;
        if (presentationEmail.id != emailIdsPresentation.keys.last) continue;
        EmailBindings(initialEmail: presentationEmail).dependencies();
        emailIdsStatus[presentationEmail.id!] = EmailInThreadStatus.expanded;
      }
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(failure) {
    if (failure is GetEmailIdsByThreadIdFailure) {
      // TODO: handle failure
      return;
    }
    super.handleFailureViewState(failure);
  }
}