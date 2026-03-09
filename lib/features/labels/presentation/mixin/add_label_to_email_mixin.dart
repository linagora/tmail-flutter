import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/emit_state_mixin.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/remove_a_label_from_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_a_label_from_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/add_label_to_email_modal.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';
import 'package:tmail_ui_user/features/thread/domain/exceptions/thread_exceptions.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

typedef OnSyncLabelForEmail = void Function(
  EmailId emailId,
  KeyWordIdentifier labelKeyword,
  bool shouldRemove,
);

mixin AddLabelToEmailMixin on EmitStateMixin {
  bool get isCurrentLabelAvailable;

  List<Label> get currentLabelList;

  AccountId? get currentAccountId;

  Session? get currentSession;

  ToastManager get currentToastManager;

  BaseController get currentController;

  AddALabelToAnEmailInteractor? get addALabelToAnEmailInteractor;

  RemoveALabelFromAnEmailInteractor? get removeALabelFromAnEmailInteractor;

  OnSyncLabelForEmail? get onSyncLabelForEmail;

  void toggleLabelToEmail(EmailId emailId, Label label, bool isSelected) {
    log('AddLabelToEmailMixin::toggleLabelToEmail: emailId is ${emailId.asString}, label is $label');
    if (isSelected) {
      _addALabelToAnEmail(emailId: emailId, label: label);
    } else {
      _removeALabelFromAnEmail(emailId: emailId, label: label);
    }
  }

  void _addALabelToAnEmail({required Label label, required EmailId emailId}) {
    log('AddLabelToEmailMixin::_addALabelToAnEmail: emailId is ${emailId.asString}, label is $label');
    final labelDisplay = label.safeDisplayName;
    final currentAccountId = this.currentAccountId;
    final currentSession = this.currentSession;

    if (currentSession == null) {
      emitFailure(
        controller: currentController,
        failure: AddALabelToAnEmailFailure(
          exception: NotFoundSessionException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    if (currentAccountId == null) {
      emitFailure(
        controller: currentController,
        failure: AddALabelToAnEmailFailure(
          exception: NotFoundAccountIdException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    final labelKeyword = label.keyword;
    if (labelKeyword == null) {
      emitFailure(
        controller: currentController,
        failure: AddALabelToAnEmailFailure(
          exception: LabelKeywordIsNull(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    if (addALabelToAnEmailInteractor == null) {
      emitFailure(
        controller: currentController,
        failure: AddALabelToAnEmailFailure(
          exception: InteractorIsNullException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    currentController.consumeState(
      addALabelToAnEmailInteractor!.execute(
        currentSession,
        currentAccountId,
        emailId,
        labelKeyword,
        labelDisplay,
      ),
    );
  }

  void _removeALabelFromAnEmail({
    required Label label,
    required EmailId emailId,
  }) {
    final labelDisplay = label.safeDisplayName;
    final currentAccountId = this.currentAccountId;
    final currentSession = this.currentSession;

    if (currentSession == null) {
      emitFailure(
        controller: currentController,
        failure: RemoveALabelFromAnEmailFailure(
          exception: NotFoundSessionException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    if (currentAccountId == null) {
      emitFailure(
        controller: currentController,
        failure: RemoveALabelFromAnEmailFailure(
          exception: NotFoundAccountIdException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    final labelKeyword = label.keyword;
    if (labelKeyword == null) {
      emitFailure(
        controller: currentController,
        failure: RemoveALabelFromAnEmailFailure(
          exception: LabelKeywordIsNull(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    if (removeALabelFromAnEmailInteractor == null) {
      emitFailure(
        controller: currentController,
        failure: RemoveALabelFromAnEmailFailure(
          exception: InteractorIsNullException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    currentController.consumeState(
      removeALabelFromAnEmailInteractor!.execute(
        currentSession,
        currentAccountId,
        emailId,
        labelKeyword,
        labelDisplay,
      ),
    );
  }

  Future<void> openAddLabelToEmailDialogModal({
    required PresentationEmail email,
    required OnCreateANewLabelAction onCreateANewLabelAction,
  }) async {
    final emailId = email.id;
    if (emailId == null) {
      logWarning(
        'AddLabelToEmailMixin::openAddLabelToEmailDialogModal: Email id is null',
      );
      return;
    }

    final labels = currentLabelList;
    final emailLabels = email.getLabelList(labels);

    final newLabel = await DialogRouter().openDialogModal(
      child: AddLabelToEmailModal(
        key: const Key('add_label_to_email_modal'),
        labels: labels,
        emailLabels: emailLabels,
        emailIds: [emailId],
        onAddLabelToEmailsCallback: (emailIds, label, isSelected) {
          if (emailIds.length == 1) {
            toggleLabelToEmail(emailIds.first, label, isSelected);
          }
        },
        onCreateANewLabelAction: onCreateANewLabelAction,
      ),
      dialogLabel: 'add-label-to-email-modal',
    );

    if (newLabel is Label) {
      toggleLabelToEmail(emailId, newLabel, true);
    }
  }

  void subscribeLabelViewStateSuccess(Success success) {
    if (success is AddALabelToAnEmailSuccess) {
      _handleAddLabelToEmailSuccess(success);
    } else if (success is RemoveALabelFromAnEmailSuccess) {
      _handleRemoveLabelFromEmailSuccess(success);
    }
  }

  void subscribeLabelViewStateFailure(Failure failure) {
    if (failure is AddALabelToAnEmailFailure) {
      _handleAddLabelToEmailFailure(failure);
    } else if (failure is RemoveALabelFromAnEmailFailure) {
      _handleRemoveLabelFromEmailFailure(failure);
    }
  }

  void _handleAddLabelToEmailSuccess(AddALabelToAnEmailSuccess success) {
    currentToastManager.showMessageSuccess(success);
    onSyncLabelForEmail?.call(
      success.emailId,
      success.labelKeyword,
      false,
    );
  }

  void _handleAddLabelToEmailFailure(AddALabelToAnEmailFailure failure) {
    currentToastManager.showMessageFailure(failure);
  }

  void _handleRemoveLabelFromEmailSuccess(
    RemoveALabelFromAnEmailSuccess success,
  ) {
    currentToastManager.showMessageSuccess(success);
    onSyncLabelForEmail?.call(
      success.emailId,
      success.labelKeyword,
      true,
    );
  }

  void _handleRemoveLabelFromEmailFailure(
    RemoveALabelFromAnEmailFailure failure,
  ) {
    currentToastManager.showMessageFailure(failure);
  }
}
