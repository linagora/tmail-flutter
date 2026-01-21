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
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart'
    as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

/// Abstract interface for providing email context to SingleEmailController.
/// This decouples SingleEmailController from MailboxDashBoardController,
/// enabling lightweight popup implementations.
abstract class EmailContextProvider {
  // ============================================
  // Session & Authentication (Essential)
  // ============================================

  /// The current JMAP session.
  Session? get session;

  /// The current account ID.
  Rxn<AccountId> get accountId;

  /// The own email address of the current user.
  Rx<String> get ownEmailAddress;

  /// List of user identities for reply functionality.
  List<Identity> get listIdentities;

  // ============================================
  // Mailbox Data (Essential)
  // ============================================

  /// Map of mailbox ID to presentation mailbox for lookup.
  Map<MailboxId, PresentationMailbox> get mapMailboxById;

  /// Map of mailbox role to mailbox ID for default mailboxes.
  Map<Role, MailboxId> get mapDefaultMailboxIdByRole;

  /// The currently selected mailbox.
  Rxn<PresentationMailbox> get selectedMailbox;

  // ============================================
  // Email State
  // ============================================

  /// The currently selected email for viewing.
  Rxn<PresentationEmail> get selectedEmail;

  /// Reactive UI action for email operations.
  Rxn<EmailUIAction> get emailUIAction;

  /// View state for observing success/failure states.
  /// Used to listen for events like UnsubscribeEmailSuccess.
  Rx<Either<Failure, Success>> get viewState;

  // ============================================
  // Email Actions
  // ============================================

  /// Move email to a different mailbox.
  void moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  );

  /// Delete an email permanently.
  void deleteEmailPermanently(PresentationEmail email);

  /// Open the composer for replying/forwarding/composing.
  void openComposer(ComposerArguments arguments);

  /// Open composer from mailto link.
  void openComposerFromMailToLink(Uri uri);

  /// Download a single attachment.
  void downloadAttachment({
    required Attachment attachment,
    bool previewerSupported = false,
    bool showBottomDownloadProgressBar = false,
    DownloadSourceView? sourceView,
  });

  /// Download all attachments as a zip file.
  void downloadAllAttachments({
    required String outputFileName,
    required EmailId? emailId,
    bool showBottomDownloadProgressBar = false,
  });

  /// Preview an attachment before downloading.
  void previewAttachment({
    required BuildContext context,
    required Attachment attachment,
    required OnPreviewOrDownloadAttachmentAction onPreviewOrDownloadAction,
    bool isDialogLoadingVisible = false,
    DownloadSourceView? sourceView,
  });

  /// Update email flags (read/unread, starred, etc.).
  void updateEmailFlagByEmailIds(
    List<EmailId> emailIds, {
    ReadActions? readAction,
    MarkStarAction? markStarAction,
    bool markAsAnswered = false,
    bool markAsForwarded = false,
    bool isLabelAdded = false,
    KeyWordIdentifier? labelKeyword,
  });

  /// Download message as EML file.
  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    bool showBottomDownloadProgressBar = false,
  });

  /// Unsubscribe from mailing list.
  void unsubscribeMail(EmailId emailId);

  /// Archive a message.
  void archiveMessage(PresentationEmail email);

  /// Show dialog to preview EML attachment.
  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentFileAction onDownloadFileAction,
  });

  // ============================================
  // UI State Management
  // ============================================

  /// Clear the selected email.
  void clearSelectedEmail();

  /// Clear the current email UI action.
  void clearEmailUIAction();

  /// Dispatch a route change in the dashboard.
  void dispatchRoute(DashboardRoutes route);

  /// Dispatch a mailbox UI action.
  void dispatchMailboxUIAction(MailboxUIAction action);

  // ============================================
  // Feature Flags
  // ============================================

  /// Whether the label feature is enabled.
  bool get isLabelFeatureEnabled;

  // ============================================
  // Popup Mode Support
  // ============================================

  /// Whether running in popup mode.
  bool get isPopupMode;

  /// Whether search is currently running.
  bool get isSearchEmailRunning;

  // ============================================
  // Download Support
  // ============================================

  /// The download controller for managing downloads.
  DownloadController get downloadController;

  // ============================================
  // Search Support
  // ============================================

  /// The search controller for search operations.
  search.SearchController get searchController;
}
