import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_an_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_loaded_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleLabelForEmailExtension on SingleEmailController {
  bool get isLabelFeatureEnabled {
    return mailboxDashBoardController.isLabelCapabilitySupported &&
        mailboxDashBoardController.labelController.isLabelSettingEnabled.isTrue;
  }

  void toggleLabelToEmail(EmailId emailId, Label label, bool isSelected) {
    if (isSelected) {
      final accountId = mailboxDashBoardController.accountId.value;

      _addALabelToAnEmail(
        accountId: accountId,
        emailId: emailId,
        label: label,
      );
    }
  }

  void _addALabelToAnEmail({
    required AccountId? accountId,
    required Label label,
    required EmailId emailId,
  }) {
    final labelDisplay = label.safeDisplayName;

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

    addALabelToAnEmailInteractor = getBinding<AddALabelToAnEmailInteractor>();
    if (addALabelToAnEmailInteractor != null) {
      consumeState(addALabelToAnEmailInteractor!.execute(
        accountId,
        emailId,
        labelKeyword,
        label.safeDisplayName,
      ));
    } else {
      consumeState(
        Stream.value(
          Left(AddALabelToAnEmailFailure(
            exception: LabelInteractorIsNull(),
            labelDisplay: labelDisplay,
          )),
        ),
      );
    }
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
    if (PlatformInfo.isMobile && !isThreadDetailEnabled) {
      _updateLabelInEmailWithThreadDisabledOnMobile(
        emailId: emailId,
        labelKeyword: labelKeyword,
      );
    } else {
      _updateLabelInEmailWithThreadEnabled(
        emailId: emailId,
        labelKeyword: labelKeyword,
      );
    }
  }

  void _updateLabelInEmailWithThreadDisabledOnMobile({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
  }) {
    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    final selectedEmailId = selectedEmail?.id;
    if (selectedEmail == null ||
        selectedEmailId == null ||
        selectedEmailId != emailId) {
      return;
    }

    mailboxDashBoardController.selectedEmail.value =
        selectedEmail.addKeyword(labelKeyword);

    final emailLoaded = currentEmailLoaded.value;
    if (emailLoaded != null) {
      currentEmailLoaded.value = emailLoaded.addEmailKeyword(
        emailId: emailId,
        keyword: labelKeyword,
      );
    }

    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      isLabelAdded: true,
      labelKeyword: labelKeyword,
    );
  }

  void _updateLabelInEmailWithThreadEnabled({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
  }) {
    final controller = threadDetailController;
    if (controller == null) return;

    final currentEmailId = currentEmail?.id;
    if (currentEmailId == null || currentEmailId != emailId) return;

    controller.emailIdsPresentation.value =
        controller.emailIdsPresentation.addEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
    );

    controller.emailsInThreadDetailInfo.value =
        controller.emailsInThreadDetailInfo.addEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
    );

    final emailLoaded = controller.currentEmailLoaded.value;
    if (emailLoaded != null) {
      controller.currentEmailLoaded.value = emailLoaded.addEmailKeyword(
        emailId: emailId,
        keyword: labelKeyword,
      );
    }

    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      isLabelAdded: true,
      labelKeyword: labelKeyword,
    );
  }
}
