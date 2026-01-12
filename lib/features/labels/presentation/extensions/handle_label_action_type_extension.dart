import 'package:core/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleLabelActionTypeExtension on LabelController {
  void handleLabelActionType({
    required BuildContext context,
    required LabelActionType actionType,
    required AccountId? accountId,
    Label? label,
  }) {
    switch (actionType) {
      case LabelActionType.delete:
        if (label == null) return;
        _openDeleteLabelModal(
          context: context,
          accountId: accountId,
          label: label,
        );
        break;
    }
  }

  Future<void> _openDeleteLabelModal({
    required BuildContext context,
    required AccountId? accountId,
    required Label label,
  }) async {
    final appLocalizations = AppLocalizations.of(context);

    MessageDialogActionManager().showConfirmDialogAction(
      context,
      appLocalizations.areYouSureYouWantToDeleteTheLabel(label.safeDisplayName),
      appLocalizations.delete,
      key: const Key('confirm_dialog_delete_label'),
      title: appLocalizations.deleteLabel,
      cancelTitle: appLocalizations.cancel,
      onConfirmAction: () => _deleteLabel(accountId: accountId, label: label),
      onCloseButtonAction: popBack,
      alignCenter: true,
      dialogMargin: MediaQuery.paddingOf(context).add(
        const EdgeInsets.only(bottom: 12),
      ),
    );
  }

  void _deleteLabel({
    required AccountId? accountId,
    required Label label,
  }) {
    log('LabelController::deleteLabel:label: $label');
    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: DeleteALabelFailure(NotFoundAccountIdException()),
      );
    } else if (deleteALabelInteractor == null) {
      emitFailure(
        controller: this,
        failure: DeleteALabelFailure(InteractorNotInitialized()),
      );
    } else {
      consumeState(deleteALabelInteractor!.execute(accountId, label));
    }
  }

  void handleDeleteLabelSuccess(DeleteALabelSuccess success) {
    toastManager.showMessageSuccess(success);
    syncListLabelsAfterDelete(success.deletedLabel);
  }

  void handleDeleteLabelFailure(DeleteALabelFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void syncListLabelsAfterDelete(Label deletedLabel) {
    labels.removeWhere((label) => label.id == deletedLabel.id);
    labels.sortByAlphabetically();
  }
}
