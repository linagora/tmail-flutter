
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/fcm_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/change_listener.dart';

class EmailChangeListener extends ChangeListener {

  MailboxDashBoardController? _dashBoardController;

  EmailChangeListener._internal() {
    try {
      _dashBoardController = Get.find<MailboxDashBoardController>();
    } catch (e) {
      logError('EmailChangeListener::_internal(): IS NOT REGISTERED: ${e.toString()}');
    }
  }

  static final EmailChangeListener _instance = EmailChangeListener._internal();

  static EmailChangeListener get instance => _instance;

  @override
  void dispatchActions(List<Action> actions) {
    log('EmailChangeListener::dispatchActions():actions: $actions');
    for (var action in actions) {
      if (action is SynchronizeEmailOnForegroundAction) {
        _synchronizeEmailOnForegroundAction(action.newState);
      } else if (action is PushNotificationAction) {
        _pushNotificationAction(action.newState, action.accountId);
      } else if (action is StoreEmailStateChangeToRefreshAction) {
        _handleStoreEmailStateChangeToRefreshAction(action.newState, action.accountId);
      }
    }
  }

  void _synchronizeEmailOnForegroundAction(jmap.State newState) {
    log('EmailChangeListener::_synchronizeEmailAction():newState: $newState');
    if (_dashBoardController != null) {
      _dashBoardController!.dispatchAction(RefreshChangedEmailAction(newState));
    }
  }

  void _pushNotificationAction(jmap.State newState, AccountId accountId) {
    log('EmailChangeListener::_pushNotificationAction():newState: $newState');
  }

  void _handleStoreEmailStateChangeToRefreshAction(jmap.State newState, AccountId accountId) {
    log('EmailChangeListener::_handleStoreEmailStateChangeToRefreshAction():newState: $newState');
  }
}