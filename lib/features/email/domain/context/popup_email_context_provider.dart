import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/email/domain/context/email_context_provider.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart'
    as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

/// Lightweight popup implementation of EmailContextProvider.
/// Fetches only essential data (session, mailboxes, identities) for displaying emails.
/// Actions like compose open in the main window.
class PopupEmailContextProvider extends ReloadableController
    implements EmailContextProvider {

  // Interactors for essential operations
  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final UnsubscribeEmailInteractor _unsubscribeEmailInteractor;
  final DownloadController _downloadController;

  PopupEmailContextProvider(
    this._getAllMailboxInteractor,
    this._getAllIdentitiesInteractor,
    this._moveToMailboxInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._unsubscribeEmailInteractor,
    this._downloadController,
  );

  // ============================================
  // State
  // ============================================

  Session? _session;
  final _accountId = Rxn<AccountId>();
  final _ownEmailAddress = ''.obs;
  List<Identity> _identities = [];
  final Map<MailboxId, PresentationMailbox> _mapMailboxById = {};
  final Map<Role, MailboxId> _mapDefaultMailboxIdByRole = {};
  final _selectedMailbox = Rxn<PresentationMailbox>();
  final _selectedEmail = Rxn<PresentationEmail>();
  final _emailUIAction = Rxn<EmailUIAction>();
  bool _isInitialized = false;

  // Flag to track initialization completion
  final isReady = false.obs;

  // ============================================
  // Initialization
  // ============================================

  @override
  void onReady() {
    super.onReady();
    _initializePopupContext();
  }

  void _initializePopupContext() {
    // Start authentication flow
    getAuthenticatedAccountAction();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetSessionSuccess) {
      _handleSessionReady(success.session);
    } else if (success is GetAllMailboxSuccess) {
      _handleMailboxesReady(success);
    } else if (success is GetAllIdentitiesSuccess) {
      _handleIdentitiesReady(success);
    } else if (success is UnsubscribeEmailSuccess) {
      // Handle unsubscribe success
    } else {
      super.handleSuccessViewState(success);
    }
  }

  void _handleSessionReady(Session session) {
    log('PopupEmailContextProvider::_handleSessionReady');
    _session = session;

    _accountId.value = session.accountId;
    _ownEmailAddress.value = session.username.value;

    // Fetch mailboxes and identities
    _fetchMailboxes();
    _fetchIdentities();
  }

  void _fetchMailboxes() {
    if (_session == null || _accountId.value == null) return;

    consumeState(
      _getAllMailboxInteractor.execute(_session!, _accountId.value!),
    );
  }

  void _handleMailboxesReady(GetAllMailboxSuccess success) {
    log('PopupEmailContextProvider::_handleMailboxesReady');
    _mapMailboxById.clear();
    _mapDefaultMailboxIdByRole.clear();

    for (final mailbox in success.mailboxList) {
      _mapMailboxById[mailbox.id] = mailbox;

      if (mailbox.role != null) {
        _mapDefaultMailboxIdByRole[mailbox.role!] = mailbox.id;
      }
    }

    _checkInitializationComplete();
  }

  void _fetchIdentities() {
    if (_session == null || _accountId.value == null) return;

    consumeState(
      _getAllIdentitiesInteractor.execute(_session!, _accountId.value!),
    );
  }

  void _handleIdentitiesReady(GetAllIdentitiesSuccess success) {
    log('PopupEmailContextProvider::_handleIdentitiesReady');
    _identities = success.identities ?? [];

    // Update own email address from default identity
    if (_identities.isNotEmpty) {
      final defaultIdentity = _identities.firstWhere(
        (identity) => identity.mayDelete == false,
        orElse: () => _identities.first,
      );
      if (defaultIdentity.email != null) {
        _ownEmailAddress.value = defaultIdentity.email!;
      }
    }

    _checkInitializationComplete();
  }

  void _checkInitializationComplete() {
    if (_session != null &&
        _mapMailboxById.isNotEmpty &&
        _identities.isNotEmpty &&
        !_isInitialized) {
      _isInitialized = true;
      isReady.value = true;
      log('PopupEmailContextProvider::_checkInitializationComplete: Ready');
    }
  }

  // ============================================
  // Session & Authentication
  // ============================================

  @override
  Session? get session => _session;

  @override
  Rxn<AccountId> get accountId => _accountId;

  @override
  Rx<String> get ownEmailAddress => _ownEmailAddress;

  @override
  List<Identity> get listIdentities => _identities;

  // ============================================
  // Mailbox Data
  // ============================================

  @override
  Map<MailboxId, PresentationMailbox> get mapMailboxById => _mapMailboxById;

  @override
  Map<Role, MailboxId> get mapDefaultMailboxIdByRole => _mapDefaultMailboxIdByRole;

  @override
  Rxn<PresentationMailbox> get selectedMailbox => _selectedMailbox;

  // ============================================
  // Email State
  // ============================================

  @override
  Rxn<PresentationEmail> get selectedEmail => _selectedEmail;

  @override
  Rxn<EmailUIAction> get emailUIAction => _emailUIAction;

  // viewState is inherited from ReloadableController

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
    final currentMailboxes = moveRequest.currentMailboxes;
    if (currentMailboxes.length == 1 && currentMailboxes.values.first.length == 1) {
      consumeState(_moveToMailboxInteractor.execute(
        session,
        accountId,
        moveRequest,
        emailIdsWithReadStatus,
      ));
    } else {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
        session,
        accountId,
        moveRequest,
        emailIdsWithReadStatus,
      ));
    }
  }

  @override
  void deleteEmailPermanently(PresentationEmail email) {
    if (_accountId.value != null && _session != null && email.id != null) {
      consumeState(_deleteEmailPermanentlyInteractor.execute(
        _session!,
        _accountId.value!,
        email.id!,
        email.mailboxContain?.id,
      ));
    }
  }

  @override
  void openComposer(ComposerArguments arguments) {
    // In popup mode, open composer in main window
    // The composer functionality is complex and requires the full dashboard context
    if (PlatformInfo.isWeb) {
      // Open the main app window - user can compose from there
      html.window.open(RouteUtils.baseOriginUrl, '_blank');
    }
  }

  @override
  void openComposerFromMailToLink(Uri uri) {
    if (PlatformInfo.isWeb) {
      html.window.open(uri.toString(), '_blank');
    }
  }

  @override
  void downloadAttachment({
    required Attachment attachment,
    bool previewerSupported = false,
    bool showBottomDownloadProgressBar = false,
    DownloadSourceView? sourceView,
  }) {
    _downloadController.downloadAttachment(
      attachment: attachment,
      accountId: _accountId.value,
      session: _session,
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
    _downloadController.downloadAllAttachments(
      outputFileName: outputFileName,
      emailId: emailId,
      accountId: _accountId.value,
      session: _session,
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
    _downloadController.previewAttachment(
      context: context,
      attachment: attachment,
      accountId: _accountId.value,
      session: _session,
      ownEmailAddress: _ownEmailAddress.value,
      sourceView: sourceView,
      onPreviewOrDownloadAction: onPreviewOrDownloadAction,
      isDialogLoadingVisible: isDialogLoadingVisible,
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
    // Popup doesn't maintain a list of emails to update
    // The flag update is handled through the email actions themselves
    log('PopupEmailContextProvider::updateEmailFlagByEmailIds: $emailIds');
  }

  @override
  void downloadMessageAsEML({
    required PresentationEmail presentationEmail,
    bool showBottomDownloadProgressBar = false,
  }) {
    _downloadController.downloadMessageAsEML(
      presentationEmail: presentationEmail,
      accountId: _accountId.value,
      session: _session,
      showBottomDownloadProgressBar: showBottomDownloadProgressBar,
    );
  }

  @override
  void unsubscribeMail(EmailId emailId) {
    if (_accountId.value != null && _session != null) {
      consumeState(
        _unsubscribeEmailInteractor.execute(
          _session!,
          _accountId.value!,
          emailId,
        ),
      );
    }
  }

  @override
  void archiveMessage(PresentationEmail email) {
    final mailboxContain = email.findMailboxContain(_mapMailboxById);
    if (mailboxContain != null && email.id != null) {
      final archiveMailboxId = _mapDefaultMailboxIdByRole[PresentationMailbox.roleArchive];
      if (archiveMailboxId != null && _session != null && _accountId.value != null) {
        final moveToArchiveMailboxRequest = MoveToMailboxRequest(
          {mailboxContain.id: [email.id!]},
          archiveMailboxId,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
        );
        moveToMailbox(
          _session!,
          _accountId.value!,
          moveToArchiveMailboxRequest,
          {email.id!: email.hasRead},
        );
      }
    }
  }

  @override
  void showDialogToPreviewEMLAttachment({
    required BuildContext context,
    required EMLPreviewer emlPreviewer,
    required ImagePaths imagePaths,
    required OnMailtoDelegateAction onMailtoAction,
    required OnDownloadAttachmentFileAction onDownloadFileAction,
  }) {
    _downloadController.showDialogToPreviewEMLAttachment(
      context: context,
      emlPreviewer: emlPreviewer,
      onMailtoAction: onMailtoAction,
      onPreviewAction: (uri) => _downloadController.openEMLPreviewer(
        appLocalizations: AppLocalizations.of(context),
        uri: uri,
        accountId: _accountId.value,
        session: _session,
        ownEmailAddress: _ownEmailAddress.value,
      ),
      onDownloadAction: (uri) async => _downloadController.downloadAttachmentInEMLPreview(
        uri: uri,
        onDownloadAction: (attachment) => downloadAttachment(
          attachment: attachment,
        ),
      ),
    );
  }

  // ============================================
  // UI State Management
  // ============================================

  @override
  void clearSelectedEmail() {
    _selectedEmail.value = null;
  }

  @override
  void clearEmailUIAction() {
    _emailUIAction.value = null;
  }

  @override
  void dispatchRoute(DashboardRoutes route) {
    // No-op in popup mode - popup doesn't have dashboard routing
    log('PopupEmailContextProvider::dispatchRoute: $route (no-op in popup)');
  }

  @override
  void dispatchMailboxUIAction(MailboxUIAction action) {
    // No-op in popup mode - popup doesn't have mailbox UI
    log('PopupEmailContextProvider::dispatchMailboxUIAction: $action (no-op in popup)');
  }

  // ============================================
  // Feature Flags
  // ============================================

  @override
  bool get isLabelFeatureEnabled => false; // Labels not supported in popup mode

  // ============================================
  // Popup Mode Support
  // ============================================

  @override
  bool get isPopupMode => true;

  @override
  bool get isSearchEmailRunning => false;

  // ============================================
  // Download Support
  // ============================================

  @override
  DownloadController get downloadController => _downloadController;

  // ============================================
  // Search Support
  // ============================================

  @override
  search.SearchController get searchController => throw UnimplementedError(
    'SearchController is not available in popup mode',
  );

  // ============================================
  // Helper Methods
  // ============================================

  MailboxId? getMailboxIdByRole(Role role) {
    return _mapDefaultMailboxIdByRole[role];
  }
}
