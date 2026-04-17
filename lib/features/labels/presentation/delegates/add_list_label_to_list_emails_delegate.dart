import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/add_list_label_to_list_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/labels/domain/model/add_list_labels_to_list_emails_params.dart';
import 'package:tmail_ui_user/features/labels/presentation/label_controller.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

class AddListLabelToListEmailsDelegate extends BaseController {
  final LabelController _labelController;
  final AddListLabelToListEmailsInteractor _interactor;

  AddListLabelToListEmailsDelegate(this._labelController, this._interactor);

  Future<void> openChooseLabelModal({
    required List<PresentationEmail> selectedEmails,
    required ImagePaths imagePaths,
    required VoidCallback onCancel,
    required OnSyncListLabelForListEmail onSync,
  }) async {
    await DialogRouter().openDialogModal(
      child: ChooseLabelModal(
        labels: _labelController.labels,
        onLabelAsToEmailsAction: (labels) {
          onCancel();
          _addLabels(
            AddListLabelsToListEmailsParams(
              labels: labels,
              emailIds: selectedEmails.listEmailIds,
              onSync: onSync,
            ),
          );
        },
        imagePaths: imagePaths,
      ),
      dialogLabel: 'choose-label-modal',
    );
  }

  void _addLabels(
    AddListLabelsToListEmailsParams params,
  ) {
    final session = _labelController.session;
    final accountId = _labelController.accountId;

    final exception = _validateParams(params.labelKeywords);
    if (exception != null) {
      emitFailure(
        controller: this,
        failure: AddListLabelsToListEmailsFailure(
          exception: exception,
          labelDisplays: params.labelDisplays,
        ),
      );
      return;
    }

    consumeState(_interactor.execute(session!, accountId!, params));
  }

  Exception? _validateParams(List<KeyWordIdentifier> keywords) {
    if (_labelController.session == null) return NotFoundSessionException();
    if (_labelController.accountId == null) return NotFoundAccountIdException();
    if (keywords.isEmpty) return const LabelKeywordIsNull();
    return null;
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is AddListLabelsToListEmailsSuccess) {
      toastManager.showMessageSuccess(success);
      success.onSync?.call(success.emailIds, success.labelKeywords, shouldRemove: false);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is AddListLabelsToListEmailsFailure) {
      toastManager.showMessageFailure(failure);
    }
  }
}
