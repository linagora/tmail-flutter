import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_email_ids_by_thread_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/thread_detail_arguments.dart';

class ThreadDetailController extends BaseController {
  final ThreadDetailArguments arguments;
  final GetEmailIdsByThreadIdInteractor _getEmailIdsByThreadIdInteractor;

  ThreadDetailController(
    this.arguments,
    this._getEmailIdsByThreadIdInteractor,
  );

  final emailIds = <EmailId>[].obs;

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

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