import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/email/domain/context/email_context_provider.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart'
    as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_download_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

/// Dashboard implementation of EmailContextProvider.
/// Delegates all operations to MailboxDashBoardController.
/// Used when SingleEmailController is running in the main dashboard context.
class DashboardEmailContextProvider implements EmailContextProvider {
  final MailboxDashBoardController _dashboardController;

  DashboardEmailContextProvider(this._dashboardController);

  // ============================================
  // Session & Authentication
  // ============================================

  @override
  Session? get session => _dashboardController.sessionCurrent;

  @override
  Rxn<AccountId> get accountId => _dashboardController.accountId;

  @override
  Rx<String> get ownEmailAddress => _dashboardController.ownEmailAddress;

  @override
  List<Identity> get listIdentities =>
      _dashboardController.listIdentities;

  // ============================================
  // Mailbox Data
  // ============================================

  @override
  Map<MailboxId, PresentationMailbox> get mapMailboxById =>
      _dashboardController.mapMailboxById;

  @override
  Map<Role, MailboxId> get mapDefaultMailboxIdByRole =>
      _dashboardController.mapDefaultMailboxIdByRole;

  @override
  Rxn<PresentationMailbox> get selectedMailbox =>
      _dashboardController.selectedMailbox;

  // ============================================
  // Email State
  // ============================================

  @override
  Rxn<PresentationEmail> get selectedEmail =>
      _dashboardController.selectedEmail;

  @override
  Rxn<EmailUIAction> get emailUIAction =>
      _dashboardController.emailUIAction;

  @override
  Rx<Either<Failure, Success>> get viewState =>
      _dashboardController.viewState;

  // ============================================
  // Email Actions
  // ============================================

  @override
  void moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    _dashboardController.moveToMailbox(
      session,
      accountId,
      moveRequest,
      emailIdsWithReadStatus,
    );
  }

  @override
  void deleteEmailPermanently(PresentationEmail email) {
    _dashboardController.deleteEmailPermanently(email);
  }

  @override
  void openComposer(ComposerArguments arguments) {
    _dashboardController.openComposer(arguments);
  }

  @override
  void openComposerFromMailToLink(Uri uri) {
    _dashboardController.openComposerFromMailToLink(uri);
  }

  @override
  void downloadAttachment({
    required Attachment attachment,
    bool previewerSupported = false,
    bool showBottomDownloadProgressBar = false,
    DownloadSourceView? sourceView,
  }) {
    _dashboardController.downloadAttachment(
      attachment: attachment,
      previewerSupported: previewerSupported,
      showBottomDownloadProgressBar: showBottomDownloadProgressBar,
      sourceView: sourceView,
    );
  }

  @override
  void downloadAllAttachments({
    required String outputFileName,
    required EmailId? emailId,
    bool showBottomDownloadProgressBar = false,
  }) {
    _dashboardController.downloadAllAttachments(
      outputFileName: outputFileName,
      emailId: emailId,
      showBottomDownloadProgressBar: showBottomDownloadProgressBar,
    );
  }

  @override
  void previewAttachment({
    required BuildContext context,
    required Attachment attachment,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
    DownloadSourceView? sourceView,
  }) {
    _dashboardController.previewAttachment(
      context: context,
      attachment: attachment,
      onPreviewOrDownloadAction: onPreviewOrDownloadAction,
      isDialogLoadingVisible: isDialogLoadingVisible,
      sourceView: sourceView,
    );
  }

  @override
  void updateEmailFlagByEmailIds(
    List<EmailId> emailIds, {
    ReadActions? readAction,
    MarkStarAction? markStarAction,
    bool markAsAnswered = false,
    bool markAsForwarded = false,
    bool isLabelAdded = false,
    KeyWordIdentifier? labelKeyword,
  }) {
    _dashboardController.updateEmailFlagByEmailIds(
      emailIds,
      readAction: readAction,
      markStarAction: markStarAction,
      markAsAnswered: markAsAnswered,
      markAsForwarded: markAsForwarded,
      isLabelAdded: isLabelAdded,
      labelKeyword: labelKeyword,
    );
  }

  @override
  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    bool showBottomDownloadProgressBar = false,
  }) {
    _dashboardController.downloadMessageAsEML(
      presentationEmail: presentationEmail,
      showBottomDownloadProgressBar: showBottomDownloadProgressBar,
    );
  }

  @override
  void unsubscribeMail(EmailId emailId) {
    _dashboardController.unsubscribeMail(emailId);
  }

  @override
  void archiveMessage(PresentationEmail email) {
    _dashboardController.archiveMessage(email);
  }

  @override
  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentFileAction onDownloadFileAction,
  }) {
    _dashboardController.showDialogToPreviewEMLAttachment(
      context: context,
      emlPreviewer: emlPreviewer,
      imagePaths: imagePaths,
      onMailtoAction: onMailtoAction,
      onDownloadFileAction: onDownloadFileAction,
    );
  }

  // ============================================
  // UI State Management
  // ============================================

  @override
  void clearSelectedEmail() {
    _dashboardController.clearSelectedEmail();
  }

  @override
  void clearEmailUIAction() {
    _dashboardController.emailUIAction.value = null;
  }

  @override
  void dispatchRoute(DashboardRoutes route) {
    _dashboardController.dispatchRoute(route);
  }

  @override
  void dispatchMailboxUIAction(MailboxUIAction action) {
    _dashboardController.dispatchMailboxUIAction(action);
  }

  // ============================================
  // Feature Flags
  // ============================================

  @override
  bool get isLabelFeatureEnabled => _dashboardController.isLabelAvailable;

  // ============================================
  // Popup Mode Support
  // ============================================

  @override
  bool get isPopupMode => _dashboardController.isPopupMode.value;

  @override
  bool get isSearchEmailRunning =>
      _dashboardController.searchController.isSearchEmailRunning;

  // ============================================
  // Download Support
  // ============================================

  @override
  DownloadController get downloadController =>
      _dashboardController.downloadController;

  // ============================================
  // Search Support
  // ============================================

  @override
  search.SearchController get searchController =>
      _dashboardController.searchController;
}
