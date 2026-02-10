import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/emit_state_mixin.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/add_list_label_to_list_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/add_list_label_to_list_emails_interactor.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/features/thread/domain/exceptions/thread_exceptions.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

typedef OnSyncListLabelForListEmail = void Function(
  List<EmailId> emailIds,
  List<KeyWordIdentifier> labelKeywords,
  {bool shouldRemove}
);

mixin AddListLabelsToListEmailsMixin on EmitStateMixin {
  AccountId? get currentAccountId;

  Session? get currentSession;

  ToastManager get currentToastManager;

  BaseController get currentController;

  AddListLabelToListEmailsInteractor? get addListLabelToListEmailInteractor;

  OnSyncListLabelForListEmail? get onSyncListLabelForListEmail;

  Future<void> openChooseLabelModal({
    required List<Label> labels,
    required List<PresentationEmail> selectedEmails,
    required ImagePaths imagePaths,
    required VoidCallback onCallBackAction,
  }) async {
    await DialogRouter().openDialogModal(
      child: ChooseLabelModal(
        labels: labels,
        onLabelAsToEmailsAction: (labels) {
          onCallBackAction();
          log(
            'AddLabelToListEmailsActionMixin::ChooseLabelModal::onLabelAsToEmailsAction: '
            'Selected labels is $labels',
          );
          _addLabelsToAnEmails(
            labels: labels,
            emailIds: selectedEmails.listEmailIds,
          );
        },
        imagePaths: imagePaths,
      ),
      dialogLabel: 'choose-label-modal',
    );
  }

  void _addLabelsToAnEmails({
    required List<Label> labels,
    required List<EmailId> emailIds,
  }) {
    final labelDisplays = labels.displayNameNotNullList;
    final currentAccountId = this.currentAccountId;
    final currentSession = this.currentSession;

    if (currentSession == null) {
      emitFailure(
        controller: currentController,
        failure: AddListLabelsToListEmailsFailure(
          exception: NotFoundSessionException(),
          labelDisplays: labelDisplays,
        ),
      );
      return;
    }

    if (currentAccountId == null) {
      emitFailure(
        controller: currentController,
        failure: AddListLabelsToListEmailsFailure(
          exception: NotFoundAccountIdException(),
          labelDisplays: labelDisplays,
        ),
      );
      return;
    }

    final labelKeywords = labels.keywords;
    if (labelKeywords.isEmpty) {
      emitFailure(
        controller: currentController,
        failure: AddListLabelsToListEmailsFailure(
          exception: LabelKeywordIsNull(),
          labelDisplays: labelDisplays,
        ),
      );
      return;
    }

    if (addListLabelToListEmailInteractor == null) {
      emitFailure(
        controller: currentController,
        failure: AddListLabelsToListEmailsFailure(
          exception: InteractorIsNullException(),
          labelDisplays: labelDisplays,
        ),
      );
      return;
    }

    currentController.consumeState(
      addListLabelToListEmailInteractor!.execute(
        currentSession,
        currentAccountId,
        emailIds,
        labelKeywords,
        labelDisplays,
      ),
    );
  }

  void subscribeListLabelViewStateSuccess(Success success) {
    if (success is AddListLabelsToListEmailsSuccess) {
      _handleAddListLabelsToListEmailsSuccess(success);
    } else if (success is AddListLabelsToListEmailsHasSomeFailure) {
      _handleAddListLabelsToListEmailsHasSomeFailure(success);
    }
  }

  void subscribeListLabelViewStateFailure(Failure failure) {
    if (failure is AddListLabelsToListEmailsFailure) {
      _handleAddListLabelsToListEmailsFailure(failure);
    }
  }

  void _handleAddListLabelsToListEmailsSuccess(
    AddListLabelsToListEmailsSuccess success,
  ) {
    currentToastManager.showMessageSuccess(success);

    onSyncListLabelForListEmail?.call(
      success.emailIds,
      success.labelKeywords,
      shouldRemove: false,
    );
  }

  void _handleAddListLabelsToListEmailsHasSomeFailure(
    AddListLabelsToListEmailsHasSomeFailure hasSomeFailure,
  ) {
    currentToastManager.showMessageSuccess(hasSomeFailure);

    onSyncListLabelForListEmail?.call(
      hasSomeFailure.emailIds,
      hasSomeFailure.labelKeywords,
      shouldRemove: false,
    );
  }

  void _handleAddListLabelsToListEmailsFailure(
    AddListLabelsToListEmailsFailure failure,
  ) {
    currentToastManager.showMessageFailure(failure);
  }
}
