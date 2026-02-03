import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/labels/presentation/extensions/handle_label_websocket_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/action/push_notification_state_change_action.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/listener/change_listener.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LabelChangeListener extends ChangeListener {
  LabelController? _labelController;

  LabelChangeListener._internal() {
    try {
      _labelController = getBinding<LabelController>();
    } catch (e) {
      logError(
          'LabelChangeListener::_internal(): IS NOT REGISTERED: ${e.toString()}');
    }
  }

  static final LabelChangeListener _instance = LabelChangeListener._internal();

  static LabelChangeListener get instance => _instance;

  @override
  void dispatchActions(List<Action> actions) {
    for (var action in actions) {
      if (action is SynchronizeLabelOnForegroundAction) {
        _synchronizeLabelOnForegroundAction(action.newState);
      }
    }
  }

  void _synchronizeLabelOnForegroundAction(jmap.State newState) {
    _labelController?.refreshLabelChanges(newState: newState);
  }
}
