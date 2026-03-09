import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/create_new_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/edit_label_interactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/create_new_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

mixin LabelModalMixin {
  Future<dynamic> openCreateNewLabelModal({
    required List<Label> labels,
    required AccountId accountId,
    required ImagePaths imagePaths,
    required VerifyNameInteractor verifyNameInteractor,
    required CreateNewLabelInteractor createNewLabelInteractor,
    required EditLabelInteractor editLabelInteractor,
  }) async {
    return DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        key: const Key('create_label_modal'),
        labels: labels,
        accountId: accountId,
        imagePaths: imagePaths,
        verifyNameInteractor: verifyNameInteractor,
        createNewLabelInteractor: createNewLabelInteractor,
        editLabelInteractor: editLabelInteractor,
      ),
      dialogLabel: 'create-new-label-modal',
    );
  }

  Future<dynamic> openEditLabelModal({
    required List<Label> labels,
    required Label selectedLabel,
    required AccountId accountId,
    required ImagePaths imagePaths,
    required VerifyNameInteractor verifyNameInteractor,
    required CreateNewLabelInteractor createNewLabelInteractor,
    required EditLabelInteractor editLabelInteractor,
  }) async {
    return DialogRouter().openDialogModal(
      child: CreateNewLabelModal(
        key: const Key('edit_label_modal'),
        labels: labels,
        accountId: accountId,
        imagePaths: imagePaths,
        selectedLabel: selectedLabel,
        actionType: LabelActionType.edit,
        verifyNameInteractor: verifyNameInteractor,
        createNewLabelInteractor: createNewLabelInteractor,
        editLabelInteractor: editLabelInteractor,
      ),
      dialogLabel: 'edit-label-modal',
    );
  }
}
