import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_loaded_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';

extension HandleLabelForEmailExtension on SingleEmailController {
  bool get isLabelAvailable {
    return mailboxDashBoardController.isLabelAvailable;
  }

  void onToggleLabelAction(EmailId? emailId, Label label, bool isSelected) {
    if (emailId == null) {
      logWarning('HandleLabelForEmailExtension::onToggleLabelAction: Email id is null');
      return;
    }
    mailboxDashBoardController.toggleLabelToEmail(
      emailId,
      label,
      isSelected,
    );
  }

  void syncLabelToSelectedEmailOnMemory({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool remove,
  }) {
    _updateLabelInEmailOnMemory(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: PlatformInfo.isMobile && !isThreadDetailEnabled,
      remove: remove,
    );
  }

  void _updateLabelInEmailOnMemory({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
    required bool remove,
  }) {
    _updateLabelOnSelectedEmailIfNeeded(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: isMobileThreadDisabled,
      remove: remove,
    );

    _updateLabelOnThreadIfNeeded(
      emailId: emailId,
      labelKeyword: labelKeyword,
      isMobileThreadDisabled: isMobileThreadDisabled,
      remove: remove,
    );

    _updateLabelOnCurrentEmailLoaded(
      emailId: emailId,
      labelKeyword: labelKeyword,
      remove: remove,
    );
  }

  void _updateLabelOnSelectedEmailIfNeeded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
    required bool remove,
  }) {
    if (!isMobileThreadDisabled) return;

    final selectedEmail = mailboxDashBoardController.selectedEmail.value;
    if (selectedEmail?.id != emailId) return;

    selectedEmail?.keywords?.toggleKeyword(
      keyword: labelKeyword,
      shouldRemove: remove,
    );
  }

  void _updateLabelOnThreadIfNeeded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool isMobileThreadDisabled,
    required bool remove,
  }) {
    if (isMobileThreadDisabled) return;

    final controller = threadDetailController;
    if (controller == null) return;

    controller.emailIdsPresentation.value =
        controller.emailIdsPresentation.toggleEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
      remove: remove,
    );

    controller.emailsInThreadDetailInfo.value =
        controller.emailsInThreadDetailInfo.toggleEmailKeywordById(
      emailId: emailId,
      keyword: labelKeyword,
      remove: remove,
    );
  }

  void _updateLabelOnCurrentEmailLoaded({
    required EmailId emailId,
    required KeyWordIdentifier labelKeyword,
    required bool remove,
  }) {
    final emailLoaded = currentEmailLoaded.value;
    if (emailLoaded == null) return;
    if (emailLoaded.emailCurrent?.id != emailId) return;

    currentEmailLoaded.value = emailLoaded.toggleEmailKeyword(
      emailId: emailId,
      keyword: labelKeyword,
      remove: remove,
    );
  }
}
