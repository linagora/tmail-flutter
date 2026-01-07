import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/domain/state/edit_label_state.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

extension HandleLabelActionTypeExtension on LabelController {
  void handleLabelActionType({
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
        onCreateNewLabelCallback: (newLabel) =>
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
      final labelRequest = EditLabelRequest(
        labelId: selectedLabel.id!,
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
}
