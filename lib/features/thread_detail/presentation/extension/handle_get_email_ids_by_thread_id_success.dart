import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailIdsByThreadIdSuccess on ThreadDetailController {
  void handleGetEmailIdsByThreadIdSuccess(
    GetThreadByIdSuccess success,
  ) {
    emailIds.value = success.emailIds;
  }
}