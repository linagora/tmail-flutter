import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_forward_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';

extension HandleErrorWhenUpdateForwardFailExtension on ForwardController {
  void handleErrorWhenUpdateForwardFail(Failure failure) {
    logError(
      'HandleErrorWhenUpdateForwardFailExtension::handleErrorWhenUpdateForwardFail: $failure',
    );
    if (failure is AddRecipientsInForwardingFailure) {
      _handleAddRecipientsInForwardingFailure(failure);
    } else if (failure is DeleteRecipientInForwardingFailure) {
      _handleDeleteRecipientInForwardingFailure(failure);
    } else if (failure is EditLocalCopyInForwardingFailure) {
      _handleEditLocalCopyInForwardingFailure(failure);
    }
  }

  void _handleAddRecipientsInForwardingFailure(
    AddRecipientsInForwardingFailure failure,
  ) {
    toastManager.showMessageFailure(failure);
  }

  void _handleDeleteRecipientInForwardingFailure(
    DeleteRecipientInForwardingFailure failure,
  ) {
    cancelSelectionMode();
    toastManager.showMessageFailure(failure);
  }

  void _handleEditLocalCopyInForwardingFailure(
    EditLocalCopyInForwardingFailure failure,
  ) {
    toastManager.showMessageFailure(failure);
  }

  void handleUpdateRecipientsSuccessWithSomeFailure({
    required TMailForward forward,
    required SetMethodException exception,
  }) {
    currentForward.value = forward;
    listRecipientForward.value = forward.listRecipientForward;
    recipientController.clearAll();
    selectionMode.value = SelectMode.INACTIVE;
    updateForwardWarningBannerState();

    toastManager.showMessageFailure(
      UpdateRecipientsInForwardingFailure(exception),
    );
  }
}
