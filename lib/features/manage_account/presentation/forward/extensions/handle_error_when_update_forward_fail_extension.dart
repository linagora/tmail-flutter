import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';
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
}
