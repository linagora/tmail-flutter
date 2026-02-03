import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:labels/extensions/list_label_extension.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_label_changes_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';

extension HandleLabelWebsocketExtension on LabelController {
  void refreshLabelChanges({required jmap.State newState}) {
    if (accountId == null ||
        session == null ||
        currentLabelState == null ||
        currentLabelState == newState ||
        isLabelSettingEnabled.isFalse) {
      return;
    }

    webSocketQueueHandler?.enqueue(WebSocketMessage(newState: newState));
  }

  Future<void> handleWebSocketMessage(WebSocketMessage message) async {
    try {
      final refreshViewState = await getLabelChangesInteractor!
          .execute(
            session!,
            accountId!,
            currentLabelState!,
          )
          .last;

      final refreshState =
          refreshViewState.foldSuccessWithResult<GetLabelChangesSuccess>();

      if (refreshState is GetLabelChangesSuccess) {
        await _handleGetLabelChangesSuccess(refreshState);
      } else {
        onDataFailureViewState(refreshState);
      }
    } catch (e, stackTrace) {
      logWarning(
          'HandleLabelWebsocketExtension::handleWebSocketMessage: Exception $e');
      onError(e, stackTrace);
    }

    if (currentLabelState != null) {
      webSocketQueueHandler
          ?.removeMessagesUpToCurrent(currentLabelState!.value);
    }
  }

  Future<void> _handleGetLabelChangesSuccess(
    GetLabelChangesSuccess success,
  ) async {
    final result = success.changesResult;

    setCurrentLabelState(result.newState);

    LabelUtils.applyLabelChanges(
      currentLabels: labels,
      created: result.createdLabels,
      updated: result.updatedLabels,
      destroyedIds: result.destroyedLabelIds,
    );

    labels.sortByAlphabetically();
    labels.refresh();
  }
}
