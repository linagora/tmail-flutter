
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker_state.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_isolate_manager.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingQueueController extends BaseController {

  final dashboardController = getBinding<MailboxDashBoardController>();
  final sendingQueueIsolateManager = getBinding<SendingQueueIsolateManager>();

  final listSendingEmailController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    sendingQueueIsolateManager?.initial(
      onData: _handleSendingQueueEvent,
      onError: (error, stackTrace) {
        logError('SendingQueueController::onInit():onError:error: $error | stackTrace: $stackTrace');
      }
    );
  }

  void _handleSendingQueueEvent(Object? event) {
    log('SendingQueueController::_handleSendingQueueEvent():event: $event');
    if (event is String) {
      final workState = WorkerState.values.firstWhereOrNull((state) => state.name == event);
      log('SendingQueueController::_handleSendingQueueEvent():workState: $workState');
      if (workState != null) {
        _refreshSendingQueue(needToReopen: true);
      }
    }
  }

  void _refreshSendingQueue({bool needToReopen = false}) {
    dashboardController?.getAllSendingEmails(needToReopen: needToReopen);
  }

  void openMailboxMenu() {
    dashboardController?.openMailboxMenuDrawer();
  }

  @override
  void onClose() {
    listSendingEmailController.dispose();
    sendingQueueIsolateManager?.release();
    super.onClose();
  }
}