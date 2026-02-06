import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/edit_label_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleLabelActionTypeExtension on LabelController {
  void handleLabelActionType({
    required BuildContext context,
    required LabelActionType actionType,
    required AccountId? accountId,
    Label? label,
  }) {
    switch (actionType) {
      case LabelActionType.create:
        openCreateNewLabelModal(accountId);
        break;
      case LabelActionType.edit:
        if (label == null) return;
        openEditLabelModal(accountId: accountId, label: label);
        break;
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

  Future<void> openEditLabelModal({
    required AccountId? accountId,
    required Label label,
  }) async {
    if (accountId == null) {
      consumeState(
        Stream.value(Left(EditLabelFailure(NotFoundAccountIdException()))),
      );
      return;
    }

    await DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        key: const Key('edit_label_modal'),
        labels: labels,
        selectedLabel: label,
        actionType: LabelActionType.edit,
        onLabelActionCallback: (newLabel) =>
          editLabel(
            accountId: accountId,
            selectedLabel: label,
            newLabel: newLabel,
          ),
      ),
      dialogLabel: 'edit-label-modal',
    );
  }

  void editLabel({
    required AccountId? accountId,
    required Label selectedLabel,
    required Label newLabel,
  }) {
    log('LabelController::editLabel:selectedLabel: $selectedLabel, newLabel: $newLabel');
    if (accountId == null) {
      consumeState(
        Stream.value(Left(EditLabelFailure(NotFoundAccountIdException()))),
      );
    } else if (editLabelInteractor == null) {
      consumeState(
        Stream.value(Left(EditLabelFailure(InteractorNotInitialized()))),
      );
    } else {
      final labelId = selectedLabel.id;

      if (labelId == null) {
        consumeState(
          Stream.value(Left(EditLabelFailure(LabelIdIsNull()))),
        );
        return;
      }

      final labelRequest = EditLabelRequest(
        labelId: labelId,
        labelKeyword: selectedLabel.keyword,
        newLabel: newLabel,
      );

      consumeState(editLabelInteractor!.execute(accountId, labelRequest));
    }
  }

  void handleEditLabelSuccess(EditLabelSuccess success) {
    toastManager.showMessageSuccess(success);
    syncListLabels(success.newLabel);
  }

  void handleEditLabelFailure(EditLabelFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void syncListLabels(Label newLabel) {
    labels.removeWhere((label) => label.id == newLabel.id);
    labels.add(newLabel);
    labels.sortByAlphabetically();
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
