import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_email_state.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_loaded_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/add_label_to_email_modal.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

extension HandleLabelForEmailExtension on SingleEmailController {
  bool get isLabelAvailable {
    return mailboxDashBoardController.isLabelAvailable;
  }

  void toggleLabelToEmail(EmailId emailId, Label label, bool isSelected) {
    if (isSelected) {
      final accountId = mailboxDashBoardController.accountId.value;
      final session = mailboxDashBoardController.sessionCurrent;

      _addALabelToAnEmail(
        session: session,
        accountId: accountId,
        emailId: emailId,
        label: label,
      );
    }
  }

  void _addALabelToAnEmail({
    required Session? session,
    required AccountId? accountId,
    required Label label,
    required EmailId emailId,
  }) {
    final labelDisplay = label.safeDisplayName;

    if (session == null) {
      consumeState(
        Stream.value(
          Left(AddALabelToAnEmailFailure(
            exception: NotFoundSessionException(),
            labelDisplay: labelDisplay,
          )),
        ),
      );
      return;
    }

    if (accountId == null) {
      consumeState(
        Stream.value(
          Left(AddALabelToAnEmailFailure(
            exception: NotFoundAccountIdException(),
            labelDisplay: labelDisplay,
          )),
        ),
      );
      return;
    }

    final labelKeyword = label.keyword;
    if (labelKeyword == null) {
      consumeState(
        Stream.value(Left(
          AddALabelToAnEmailFailure(
            exception: LabelKeywordIsNull(),
            labelDisplay: labelDisplay,
          ),
        )),
      );
      return;
    }

    consumeState(addALabelToAnEmailInteractor.execute(
      session,
      accountId,
      emailId,
      labelKeyword,
      label.safeDisplayName,
    ));
  }

  void handleAddLabelToEmailSuccess(AddALabelToAnEmailSuccess success) {
    toastManager.showMessageSuccess(success);

    _autoSyncLabelToSelectedEmailOnMemory(
      emailId: success.emailId,
      labelKeyword: success.labelKeyword,
    );
  }

  void handleAddLabelToEmailFailure(AddALabelToAnEmailFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void _autoSyncLabelToSelectedEmailOnMemory({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
  }) {
    _updateLabelInEmailOnMemory(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: PlatformInfo.isMobile && !isThreadDetailEnabled,
    );
  }

  void _updateLabelInEmailOnMemory({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
  }) {
    _updateLabelOnSelectedEmailIfNeeded(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: isMobileThreadDisabled,
    );

    _updateLabelOnThreadIfNeeded(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: isMobileThreadDisabled,
    );

    _updateLabelOnCurrentEmailLoaded(
      emailId: emailId,
      labelKeyword: labelKeyword,
    );

    _notifyLabelUpdated(
      emailId: emailId,
      labelKeyword: labelKeyword,
    );
  }

  void _updateLabelOnSelectedEmailIfNeeded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
  }) {
    if (!isMobileThreadDisabled) return;

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (selectedEmail?.id != emailId) return;

    selectedEmail?.keywords?.addKeyword(labelKeyword);
  }

  void _updateLabelOnThreadIfNeeded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
  }) {
    if (isMobileThreadDisabled) return;

    final controller = threadDetailController;
    if (controller == null) return;

    controller.emailIdsPresentation.value =
        controller.emailIdsPresentation.toggleEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
      remove: false,
    );

    controller.emailsInThreadDetailInfo.value =
        controller.emailsInThreadDetailInfo.toggleEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
      remove: false,
    );
  }

  void _updateLabelOnCurrentEmailLoaded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
  }) {
    final emailLoaded = currentEmailLoaded.value;
    if (emailLoaded == null) return;
    if (emailLoaded.emailCurrent?.id != emailId) return;

    currentEmailLoaded.value = emailLoaded.toggleEmailKeyword(
      emailId: emailId,
      keyword: labelKeyword,
      remove: false,
    );
  }

  void _notifyLabelUpdated({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
  }) {
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      isLabelAdded: true,
      labelKeyword: labelKeyword,
    );

    mailboxDashBoardController.labelController.isLabelSettingEnabled.refresh();
  }

  Future<void> openAddLabelToEmailDialogModal(PresentationEmail email) async {
    if (!isLabelAvailable) return;
    final labels = mailboxDashBoardController.labelController.labels;
    final emailLabels = email.getLabelList(labels);
    final emailId = email.id;
    if (emailId == null || labels.isEmpty) {
      return;
    }

    await DialogRouter().openDialogModal(
      child: AddLabelToEmailModal(
        labels: labels,
        emailLabels: emailLabels,
        emailIds: [emailId],
        onAddLabelToEmailsCallback: (emailIds, label, isSelected) {
          if (emailIds.length == 1) {
            toggleLabelToEmail(emailIds.first, label, isSelected);
          }
        },
      ),
      dialogLabel: 'add-label-to-email-modal',
    );
  }
}
