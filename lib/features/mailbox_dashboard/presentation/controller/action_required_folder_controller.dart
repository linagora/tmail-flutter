import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/action_required_interactor_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/exceptions/thread_exceptions.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_count_emails_in_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_count_unread_emails_in_folder_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ActionRequiredFolderController extends BaseController {
  final actionRequiredFolderCount = RxInt(0);

  GetCountUnreadEmailsInFolderInteractor?
      _getCountUnreadEmailsInFolderInteractor;

  void injectBinding() {
    ActionRequiredInteractorBindings().dependencies();

    _getCountUnreadEmailsInFolderInteractor =
        getBinding<GetCountUnreadEmailsInFolderInteractor>();
  }

  Future<void> getCountEmails({
    required Session? session,
    required AccountId? accountId,
  }) async {
    if (_getCountUnreadEmailsInFolderInteractor == null) {
      consumeState(Stream.value(
        Left(GetCountUnreadEmailsInFolderFailure(InteractorIsNullException())),
      ));
      return;
    }

    if (session == null) {
      consumeState(Stream.value(
        Left(GetCountUnreadEmailsInFolderFailure(NotFoundSessionException())),
      ));
      return;
    }

    if (accountId == null) {
      consumeState(Stream.value(
        Left(GetCountUnreadEmailsInFolderFailure(NotFoundAccountIdException())),
      ));
      return;
    }

    consumeState(_getCountUnreadEmailsInFolderInteractor!.execute(
      session: session,
      accountId: accountId,
    ));
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetCountUnreadEmailsInFolderSuccess) {
      actionRequiredFolderCount.value = success.count;
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetCountUnreadEmailsInFolderFailure) {
      actionRequiredFolderCount.value = 0;
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    _getCountUnreadEmailsInFolderInteractor = null;
    super.onClose();
  }
}
