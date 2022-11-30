
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/fcm_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/change_listener.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxChangeListener extends ChangeListener {

  MailboxDashBoardController? _dashBoardController;

  MailboxChangeListener._internal() {
    try {
      _dashBoardController = getBinding<MailboxDashBoardController>();
    } catch (e) {
      logError('MailboxChangeListener::_internal(): IS NOT REGISTERED: ${e.toString()}');
    }
  }

  static final MailboxChangeListener _instance = MailboxChangeListener._internal();

  static MailboxChangeListener get instance => _instance;

  @override
  void dispatchActions(List<Action> actions) {
    log('MailboxChangeListener::dispatchActions():actions: $actions');
    for (var action in actions) {
      if (action is SynchronizeMailboxOnForegroundAction) {
        _synchronizeMailboxOnForegroundAction(action.newState);
      }
    }
  }

  void _synchronizeMailboxOnForegroundAction(jmap.State newState) {
    log('MailboxChangeListener::_synchronizeMailboxOnForegroundAction():newState: $newState');
    if (_dashBoardController != null) {
      _dashBoardController!.dispatchAction(RefreshChangeMailboxAction(newState));
    }
  }
}