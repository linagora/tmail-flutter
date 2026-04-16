import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/edit_label_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleLabelActionTypeExtension on LabelController {
  void handleLabelActionType({
    required LabelActionType actionType,
    required AccountId? accountId,
    Label? label,
    OnLabelActionCallback? onLabelActionCallback,
  }) {
    switch (actionType) {
      case LabelActionType.create:
        onCreateALabelAction(
          accountId: accountId,
          onLabelActionCallback: onLabelActionCallback,
        );
        break;
      case LabelActionType.edit:
        if (label == null) return;
        onEditLabelAction(accountId: accountId, label: label);
        break;
      case LabelActionType.delete:
        if (label == null) return;
        _openDeleteLabelModal(accountId: accountId, label: label);
        break;
    }
  }

  Future<void> onEditLabelAction({
    required AccountId? accountId,
    required Label label,
  }) async {
    final verifyNameInteractor = getBinding<VerifyNameInteractor>();
    if (verifyNameInteractor == null) {
      _handleEditLabelFailure(EditLabelFailure(const InteractorNotInitialized()));
      return;
    }

    if (accountId == null) {
      _handleEditLabelFailure(EditLabelFailure(NotFoundAccountIdException()));
      return;
    }

    final resultState = await openEditLabelModal(
      selectedLabel: label,
      accountId: accountId,
      verifyNameInteractor: verifyNameInteractor,
    );

    if (resultState is EditLabelSuccess) {
      _handleEditLabelSuccess(resultState);
    } else if (resultState is EditLabelFailure) {
      _handleEditLabelFailure(resultState);
    }
  }

  void _handleEditLabelSuccess(EditLabelSuccess success) {
    toastManager.showMessageSuccess(success);
    syncListLabels(success.newLabel);
  }

  void _handleEditLabelFailure(EditLabelFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void syncListLabels(Label newLabel) {
    labels.removeWhere((label) => label.id == newLabel.id);
    labels.add(newLabel);
    labels.sortByAlphabetically();
  }

  Future<void> _openDeleteLabelModal({
    required AccountId? accountId,
    required Label label,
  }) async {
    final context = currentContext;
    if (context == null) return;

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
        failure: DeleteALabelFailure(const InteractorNotInitialized()),
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
