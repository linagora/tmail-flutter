import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailIdsByThreadIdSuccess on ThreadDetailController {
  void handleGetEmailIdsByThreadIdSuccess(
    GetThreadByIdSuccess success,
  ) {
    if (success.emailIds.isNotEmpty) {
      emailIds.value = success.emailIds;
    } else if (mailboxDashBoardController.selectedEmail.value?.id != null) {
      emailIds.value = [mailboxDashBoardController.selectedEmail.value!.id!];
    }
  }
}