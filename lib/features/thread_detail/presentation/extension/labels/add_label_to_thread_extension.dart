import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_thread_state.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_loaded_extension.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/add_label_to_email_modal.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/remove_label_from_thread_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';

extension AddLabelToThreadExtension on ThreadDetailController {
  Future<void> openAddLabelToEmailDialogModal() async {
    if (!mailboxDashBoardController.isLabelFeatureEnabled) return;

    final labels = mailboxDashBoardController.labelController.labels;
    if (emailsInThreadDetailInfo.isEmpty || labels.isEmpty) {
      return;
    }

    final threadLabels =
        emailsInThreadDetailInfo.findCommonLabelsInThread(labels: labels);

    final emailIds = emailsInThreadDetailInfo.emailIdsToDisplay(true);

    await DialogRouter().openDialogModal(
      child: AddLabelToEmailModal(
        labels: labels,
        emailLabels: threadLabels,
        emailIds: emailIds,
        onAddLabelToEmailsCallback: (emailIds, label, isSelected) {
          toggleLabelToThread(label, isSelected, currentEmailIds: emailIds);
        },
      ),
      dialogLabel: 'add-label-to-thread-modal',
    );
  }

  void toggleLabelToThread(
    Label label,
    bool isSelected, {
    List<EmailId>? currentEmailIds,
  }) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final emailIds =
        currentEmailIds ?? emailsInThreadDetailInfo.emailIdsToDisplay(true);

    if (isSelected) {
      _addALabelToAThread(
        session: session,
        accountId: accountId,
        emailIds: emailIds,
        label: label,
      );
    } else {
      removeALabelFromAThread(
        session: session,
        accountId: accountId,
        emailIds: emailIds,
        label: label,
      );
    }
  }

  void _addALabelToAThread({
    required Session? session,
    required AccountId? accountId,
    required Label label,
    required List<EmailId> emailIds,
  }) {
    final labelDisplay = label.safeDisplayName;

    if (session == null) {
      consumeState(
        Stream.value(
          Left(AddALabelToAThreadFailure(
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
          Left(AddALabelToAThreadFailure(
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
          AddALabelToAThreadFailure(
            exception: LabelKeywordIsNull(),
            labelDisplay: labelDisplay,
          ),
        )),
      );
      return;
    }

    consumeState(addALabelToAThreadInteractor.execute(
      session,
      accountId,
      emailIds,
      labelKeyword,
      label.safeDisplayName,
    ));
  }

  void handleAddLabelToThreadSuccess(AddALabelToAThreadSuccess success) {
    toastManager.showMessageSuccess(success);

    autoSyncLabelToThreadOnMemory(
      emailIds: success.emailIds,
      labelKeyword: success.labelKeyword,
    );
  }

  void handleAddLabelToThreadFailure(AddALabelToAThreadFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void autoSyncLabelToThreadOnMemory({
    required List<EmailId> emailIds,
    required KeyWordIdentifier labelKeyword,
    bool remove = false,
  }) {
    _updateLabelInThreadOnMemory(
      emailIds: emailIds,
      labelKeyword: labelKeyword,
      remove: remove,
    );
  }

  void _updateLabelInThreadOnMemory({
    required List<EmailId> emailIds,
    required KeyWordIdentifier labelKeyword,
    required bool remove,
  }) {
    _updateEmailsInThread(emailIds, labelKeyword, remove);
    _updateCurrentLoadedEmailIfNeeded(emailIds, labelKeyword, remove);
    _updateMailboxDashboard(emailIds, labelKeyword, remove);
    _refreshLabelSettingState();
  }

  void _updateEmailsInThread(
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
    bool remove,
  ) {
    emailIdsPresentation.value =
        emailIdsPresentation.toggleListEmailsKeywordByIds(
      emailIds: emailIds,
      keyword: labelKeyword,
      remove: remove,
    );

    emailsInThreadDetailInfo.value =
        emailsInThreadDetailInfo.toggleListEmailsKeywordByIds(
      emailIds: emailIds,
      keyword: labelKeyword,
      remove: remove,
    );
  }

  void _updateCurrentLoadedEmailIfNeeded(
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
    bool remove,
  ) {
    final emailLoaded = currentEmailLoaded.value;
    final emailLoadedId = emailLoaded?.emailCurrent?.id;

    if (emailLoadedId == null || !emailIds.contains(emailLoadedId)) {
      return;
    }

    currentEmailLoaded.value = emailLoaded!.toggleEmailKeyword(
      emailId: emailLoadedId,
      keyword: labelKeyword,
      remove: remove,
    );
  }

  void _updateMailboxDashboard(
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
    bool remove,
  ) {
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      emailIds,
      isLabelAdded: !remove,
      labelKeyword: labelKeyword,
    );
  }

  void _refreshLabelSettingState() {
    mailboxDashBoardController.labelController.isLabelSettingEnabled.refresh();
  }
}
