import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/extensions/handle_mailbox_action_type_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/launcher_application_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_action_handler_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/constants/mailbox_constants.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/null_session_or_accountid_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subaddressing_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_default_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_folder_content_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subaddressing_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_action_required_tab_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_navigation_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/other_user_account_mailboxes.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/open_mailbox_view_event.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_ai_needs_action_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_account_resolver_mixin.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class MailboxController extends BaseMailboxController
    with MailboxActionHandlerMixin,
        ContactSupportMixin,
        LauncherApplicationMixin,
        MailboxAccountResolverMixin,
        MailboxWidgetMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  @override
  AccountId? get primaryAccountId => mailboxDashBoardController.accountId.value;
  final isMailboxListScrollable = false.obs;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;
  final SubscribeMailboxInteractor _subscribeMailboxInteractor;
  final SubscribeMultipleMailboxInteractor _subscribeMultipleMailboxInteractor;
  final SubaddressingInteractor _subaddressingInteractor;
  final CreateDefaultMailboxInteractor _createDefaultMailboxInteractor;
  final MoveFolderContentInteractor _moveFolderContentInteractor;
  final GetAllMailboxInteractor _sharedMailboxGetAllMailboxInteractor;

  /// Loaded mailboxes for each other user's (delegated) account.
  final Map<AccountId, OtherUserAccountMailboxes> _otherUserAccounts = {};

  /// Accounts whose mailboxes are being fetched right now. Tracked separately
  /// from [_otherUserAccounts] so a failed or in-progress load never marks an
  /// account as loaded, leaving it free to retry.
  final Set<AccountId> _otherUserAccountsInFlight = {};

  /// The primary account the other-user caches were populated for, so they can
  /// be cleared when the user switches accounts.
  AccountId? _lastPrimaryAccountId;

  /// Last known primary-account mailboxes, already filtered (subscribed and
  /// default, virtual folders removed). The single source of truth for every
  /// tree rebuild, so a primary refresh never drops the cached other-user
  /// subtrees.
  List<PresentationMailbox> _primaryMailboxes = const [];

  IOSSharingManager? _iosSharingManager;
  late MailboxActionReactor mailboxActionReactor;

  final _activeScrollTop = RxBool(false);
  final _activeScrollBottom = RxBool(true);
  final foldersExpandMode = Rx(ExpandMode.EXPAND);

  MailboxId? _newFolderId;
  NavigationRouter? _navigationRouter;
  WebSocketQueueHandler? _webSocketQueueHandler;
  Worker? isLabelsLoadedWorker;

  final _openMailboxEventController = StreamController<OpenMailboxViewEvent>();
  StreamSubscription? _openMailboxEventStreamSubscription;
  final mailboxListScrollController = ScrollController();

  PresentationMailbox? get selectedMailbox => mailboxDashBoardController.selectedMailbox.value;

  PresentationEmail? get selectedEmail => mailboxDashBoardController.selectedEmail.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  @override
  Session? get session => mailboxDashBoardController.sessionCurrent;

  MailboxController(
    this._createNewMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._renameMailboxInteractor,
    this._moveMailboxInteractor,
    this._subscribeMailboxInteractor,
    this._subscribeMultipleMailboxInteractor,
    this._subaddressingInteractor,
    this._createDefaultMailboxInteractor,
    this._moveFolderContentInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor  refreshAllMailboxInteractor,
  ) : _sharedMailboxGetAllMailboxInteractor = getAllMailboxInteractor, super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor,
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    _initWebSocketQueueHandler();
    mailboxActionReactor = MailboxActionReactor(
      _moveFolderContentInteractor
    );
    super.onInit();
  }

  @override
  void onReady() {
    _openMailboxEventStreamSubscription = _openMailboxEventController
      .stream
      .debounceTime(const Duration(milliseconds: 500))
      .listen((event) {
        if (!event.buildContext.mounted) return;
        _handleOpenMailbox(event.buildContext, event.presentationMailbox);
      });
    _initCollapseMailboxCategories();
    mailboxListScrollController.addListener(_mailboxListScrollControllerListener,);
    super.onReady();
  }

  @override
  void onClose() {
    _openMailboxEventStreamSubscription?.cancel();
    _openMailboxEventStreamSubscription = null;
    _openMailboxEventController.close();
    mailboxListScrollController.dispose();
    _webSocketQueueHandler?.dispose();
    isLabelsLoadedWorker?.dispose();
    isLabelsLoadedWorker = null;
    _resetOtherUserAccounts();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllMailboxSuccess) {
      _handleGetAllMailboxSuccess(success);
    } else if (success is CreateNewMailboxSuccess) {
      _createNewMailboxSuccess(success);
    } else if (success is DeleteMultipleMailboxAllSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState,);
    } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState,);
    } else if (success is RenameMailboxSuccess) {
      _renameMailboxSuccess(success);
    } else if (success is MoveMailboxSuccess) {
      _moveMailboxSuccess(success);
    } else if (success is SubscribeMailboxSuccess) {
      _handleUnsubscribeMailboxSuccess(success);
    } else if (success is SubscribeMultipleMailboxAllSuccess) {
      _handleUnsubscribeMultipleMailboxAllSuccess(success);
    } else if (success is SubscribeMultipleMailboxHasSomeSuccess) {
      _handleUnsubscribeMultipleMailboxHasSomeSuccess(success);
    } else if (success is SubaddressingSuccess) {
      handleSubAddressingSuccess(success);
    } else if (success is CreateDefaultMailboxAllSuccess) {
      _handleCreateDefaultFolderIfMissingSuccess(success);
    } else if (success is MoveFolderContentSuccess) {
      handleMoveFolderContentSuccess(
        success: success,
        mailboxActionReactor: mailboxActionReactor,
        dashboardController: mailboxDashBoardController,
        baseMailboxController: this,
      );
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is CreateNewMailboxFailure) {
      _createNewMailboxFailure(failure);
    } else if (failure is RenameMailboxFailure) {
      _renameMailboxFailure(failure);
    } else if (failure is DeleteMultipleMailboxFailure) {
      _deleteMailboxFailure(failure);
    } else if (failure is SubaddressingFailure) {
      handleSubAddressingFailure(failure);
    } else if (failure is MoveFolderContentFailure) {
      handleMoveFolderContentFailure(
        failure: failure,
        dashboardController: mailboxDashBoardController,
        toastManager: toastManager,
      );
    } else if (failure is CreateDefaultMailboxFailure) {
      _applyVirtualFoldersOnly();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onDone() {
    super.onDone();
    viewState.value.fold(
      (failure) {
        if (failure is GetAllMailboxFailure) {
          _applyVirtualFoldersOnly();
          mailboxDashBoardController.updateRefreshAllMailboxState(Left(RefreshAllMailboxFailure()),);
          showRetryToast(failure);
        }
      },
      (success) {
        if (success is GetAllMailboxSuccess) {
          mailboxDashBoardController.updateRefreshAllMailboxState(Right(RefreshAllMailboxSuccess()),);
          _handleCreateDefaultFolderIfMissing(mailboxDashBoardController.mapDefaultMailboxIdByRole,);
          _handleDataFromNavigationRouter();
          mailboxDashBoardController.refreshSpamReportBanner();
          if (PlatformInfo.isIOS) {
            _updateMailboxIdsBlockNotificationToKeychain(success.mailboxList);
          }
        }
      },
    );
  }

  /// Clears every other-user cache, e.g. when the primary account changes.
  void _resetOtherUserAccounts() {
    _otherUserAccounts.clear();
    _otherUserAccountsInFlight.clear();
    _lastPrimaryAccountId = null;
  }

  /// Loads each delegated account's mailboxes concurrently, rebuilding the
  /// sidebar as each one arrives so the section fills in progressively.
  Future<void> _loadOtherUserMailboxes(
    Session session,
    AccountId primary,
  ) async {
    final accountIds =
        MailboxUtils.resolveOtherUserAccountIds(session, primary);

    await Future.wait(
      accountIds.map((accountId) => _loadOtherUserAccount(session, accountId)),
    );
  }

  Future<void> _loadOtherUserAccount(
    Session session,
    AccountId accountId,
  ) async {
    if (_otherUserAccountsInFlight.contains(accountId) ||
        _otherUserAccounts.containsKey(accountId)) {
      return;
    }
    // Capture the primary account this load belongs to. If the user switches
    // primary account before the stream emits, the result is stale and must be
    // dropped, otherwise the previous account's delegates reappear.
    final loadingForPrimary = _lastPrimaryAccountId;
    _otherUserAccountsInFlight.add(accountId);

    try {
      // Run the interactor directly rather than through consumeState:
      // handleSuccessViewState would route its GetAllMailboxSuccess into
      // _handleGetAllMailboxSuccess and clobber the primary tree.
      await for (final result
          in _sharedMailboxGetAllMailboxInteractor.execute(session, accountId)) {
        final success = result.fold<GetAllMailboxSuccess?>(
          (failure) {
            logWarning(
              'MailboxController::_loadOtherUserAccount: failure '
              'account=${accountId.id.value} failure=$failure',
            );
            return null;
          },
          (success) => success is GetAllMailboxSuccess ? success : null,
        );
        if (success == null) continue;

        // The primary account changed while this load was in flight: drop the
        // result so a former account's delegates do not reappear.
        if (_lastPrimaryAccountId != loadingForPrimary) return;

        // Ghost account: the JMAP session lists it but the user has no readable
        // mailbox in it. Skip it so it never appears in the sidebar.
        final readableMailboxes = success.mailboxList.listReadableMailboxes;
        if (readableMailboxes.isEmpty) continue;

        // Delegated accounts are filtered strictly by subscription (no isDefault
        // override), so the user curates exactly which of another user's folders
        // appear by (un)subscribing to them. Stamp the James-style
        // `Delegated[owner]` namespace so they fold into Team-mailboxes with the
        // owner shown as a subtitle; accountId still routes their write actions.
        final ownerName =
            session.accounts[accountId]?.name.value ?? accountId.id.value;
        final mailboxes = readableMailboxes
            .listSubscribedMailboxes
            .map((mailbox) => mailbox.copyWith(
                  accountId: accountId,
                  isSharedAccount: true,
                  namespace: MailboxUtils.delegatedNamespace(ownerName),
                ))
            .toList();

        _otherUserAccounts[accountId] = OtherUserAccountMailboxes(
          accountId: accountId,
          displayName: MailboxName(ownerName),
          mailboxes: mailboxes,
          mailboxState: success.currentMailboxState,
        );

        await _rebuildAllTrees(selectDefaultMailbox: false);
      }
    } finally {
      _otherUserAccountsInFlight.remove(accountId);
    }
  }

  /// Refreshes the already-loaded delegated accounts off the primary account's
  /// change signal. The primary Mailbox/changes push says nothing about a
  /// delegated account's state, so this is a pragmatic approximation until each
  /// account has its own push subscription.
  Future<void> _refreshOtherUserMailboxes(Session session) async {
    var changed = false;
    for (final account in _otherUserAccounts.values.toList()) {
      final state = account.mailboxState;
      if (state == null) continue;

      final refreshViewState = await refreshAllMailboxInteractor!
          .execute(
            session,
            account.accountId,
            state,
            properties: MailboxConstants.propertiesDefault,
          )
          .last;
      final refreshState = refreshViewState
          .foldSuccessWithResult<RefreshChangesAllMailboxSuccess>();
      if (refreshState is! RefreshChangesAllMailboxSuccess) continue;

      // Delegated accounts are filtered strictly by subscription so an IMAP
      // unsubscribe hides the folder on the next refresh (see
      // _loadOtherUserAccount). Unreadable mailboxes are excluded too.
      final mailboxes = refreshState.mailboxList
          .listReadableMailboxes
          .listSubscribedMailboxes
          .map((mailbox) => mailbox.copyWith(
                accountId: account.accountId,
                isSharedAccount: true,
                namespace:
                    MailboxUtils.delegatedNamespace(account.displayName.name),
              ))
          .toList();
      _otherUserAccounts[account.accountId] = account.copyWith(
        mailboxes: mailboxes,
        mailboxState: refreshState.currentMailboxState,
      );
      changed = true;
    }

    if (changed) {
      await _rebuildAllTrees(refreshOnly: true);
    }
  }

  /// Re-fetches every already-loaded delegated account in full and rebuilds.
  ///
  /// A subscription toggle does not advance the mailbox modseq that
  /// Mailbox/changes relies on (IMAP subscriptions are a separate per-user
  /// list), so [_refreshOtherUserMailboxes] cannot observe an (un)subscribe.
  /// Only a full Mailbox/get reflects it, so this is used on the manual refresh
  /// and when returning from the Mailbox visibility settings, where the sidebar
  /// was otherwise stale until a page reload.
  Future<void> _reloadOtherUserMailboxesInFull(Session session) async {
    final accountIds = _otherUserAccounts.keys.toList();
    if (accountIds.isEmpty) return;

    await Future.wait(accountIds.map((accountId) async {
      final existing = _otherUserAccounts[accountId];
      if (existing == null) return;

      await for (final result
          in _sharedMailboxGetAllMailboxInteractor.execute(session, accountId)) {
        final success = result.fold<GetAllMailboxSuccess?>(
          (_) => null,
          (s) => s is GetAllMailboxSuccess ? s : null,
        );
        if (success == null) continue;

        final mailboxes = success.mailboxList.listReadableMailboxes
            .listSubscribedMailboxes
            .map((mailbox) => mailbox.copyWith(
                  accountId: accountId,
                  isSharedAccount: true,
                  namespace: MailboxUtils.delegatedNamespace(
                      existing.displayName.name),
                ))
            .toList();
        _otherUserAccounts[accountId] = existing.copyWith(
          mailboxes: mailboxes,
          mailboxState: success.currentMailboxState,
        );
      }
    }));

    await _rebuildAllTrees(refreshOnly: true);
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.accountId, (accountId) {
      final currentSession = session;
      final currentAccountId = accountId;

      if (currentAccountId != null && currentSession != null) {
        if (currentAccountId != _lastPrimaryAccountId) {
          _resetOtherUserAccounts();
          _lastPrimaryAccountId = currentAccountId;
        }

        getAllMailbox(currentSession, currentAccountId);
        unawaited(
          _loadOtherUserMailboxes(currentSession, currentAccountId),
        );
      }
    });

    ever<Map<String, dynamic>?>(
      mailboxDashBoardController.routerParameters,
      _handleNavigationRouteParameters,
    );

    ever(mailboxDashBoardController.mailboxUIAction, _handleMailboxUIAction);

    ever(mailboxDashBoardController.viewState, (viewState) {
      final reactionState = viewState.getOrElse(() => UIState.idle);
      if (reactionState is MarkAsEmailReadSuccess) {
        _handleMarkEmailsAsReadOrUnread(
          affectedMailboxId: reactionState.mailboxId,
          readCount: reactionState.readActions == ReadActions.markAsRead
            ? 1
            : null,
          unreadCount: reactionState.readActions == ReadActions.markAsUnread
            ? 1
            : null,
        );
      } else if (reactionState is MarkAsMultipleEmailReadAllSuccess) {
        for (var emailIdsByMailboxId in reactionState.markSuccessEmailIdsByMailboxId.entries) {
          _handleMarkEmailsAsReadOrUnread(
            affectedMailboxId: emailIdsByMailboxId.key,
            readCount: reactionState.readActions == ReadActions.markAsRead
              ? emailIdsByMailboxId.value.length
              : null,
            unreadCount: reactionState.readActions == ReadActions.markAsUnread
              ? emailIdsByMailboxId.value.length
              : null,
          );
        }
      } else if (reactionState is MarkAsMultipleEmailReadHasSomeEmailFailure) {
        for (var emailIdsByMailboxId in reactionState.markSuccessEmailIdsByMailboxId.entries) {
          _handleMarkEmailsAsReadOrUnread(
            affectedMailboxId: emailIdsByMailboxId.key,
            readCount: reactionState.readActions == ReadActions.markAsRead
              ? emailIdsByMailboxId.value.length
              : null,
            unreadCount: reactionState.readActions == ReadActions.markAsUnread
              ? emailIdsByMailboxId.value.length
              : null,
          );
        }
      } else if (reactionState is MarkAsMailboxReadAllSuccess) {
        _handleMarkMailboxAsRead(
          affectedMailboxId: reactionState.mailboxId
        );
      } else if (reactionState is MarkAsMailboxReadHasSomeEmailFailure) {
        _handleMarkEmailsAsReadOrUnread(
          affectedMailboxId: reactionState.mailboxId,
          readCount: reactionState.successEmailIds.length,
        );
      } else if (reactionState is GetRestoredDeletedMessageCompleted) {
        _handleMarkEmailsAsReadOrUnread(
          affectedMailboxId: reactionState.recoveredMailbox?.id,
          unreadCount: reactionState
            .emailRecoveryAction
            .successfulRestoreCount
            ?.value
            .toInt() ?? 0,
        );
      } else if (reactionState is SaveEmailAsDraftsSuccess) {
        _handleDraftSaved(
          affectedMailboxId: reactionState.draftMailboxId,
          totalEmailsChanged: 1,
        );
      } else if (reactionState is RemoveEmailDraftsSuccess) {
        _handleDraftSaved(
          affectedMailboxId: reactionState.draftMailboxId,
          totalEmailsChanged: -1,
        );
      } else if (reactionState is DeleteEmailPermanentlySuccess) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -1,
        );
      } else if (reactionState is DeleteMultipleEmailsPermanentlyAllSuccess) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -reactionState.emailIds.length,
        );
      } else if (reactionState is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -reactionState.emailIds.length,
        );
      } else if (reactionState is EmptyTrashFolderSuccess) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -reactionState.emailIds.length,
        );
      } else if (reactionState is EmptySpamFolderSuccess) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -reactionState.emailIds.length,
        );
      } else if (reactionState is MoveToMailboxSuccess) {
        _handleMoveEmailsToMailbox(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
          emailIdsWithReadStatus: reactionState.emailIdsWithReadStatus,
        );
      } else if (reactionState is MoveMultipleEmailToMailboxAllSuccess) {
        _handleMoveEmailsToMailbox(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
          emailIdsWithReadStatus: reactionState.emailIdsWithReadStatus,
        );
      } else if (reactionState is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
        _handleMoveEmailsToMailbox(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithMoveSucceededEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
          emailIdsWithReadStatus: reactionState.moveSucceededEmailIdsWithReadStatus,
        );
      } else if (reactionState is ClearMailboxSuccess) {
        _handleDeleteEmailsFromMailbox(
          affectedMailboxId: reactionState.mailboxId,
          totalEmailsChanged: -reactionState.totalDeletedMessages.value.toInt(),
        );
      }
    });
  }

  void _handleMailboxUIAction(MailboxUIAction? action) {
    if (action is SelectMailboxDefaultAction) {
      _switchBackToMailboxDefault();
      mailboxDashBoardController.clearMailboxUIAction();
    } else if (action is RefreshChangeMailboxAction) {
      _refreshMailboxChanges(newState: action.newState);
    } else if (action is OpenMailboxAction) {
      _onOpenMailboxAction(action);
    } else if (action is SystemBackToInboxAction) {
      _disableAllSearchEmail();
      _switchBackToMailboxDefault();
      mailboxDashBoardController.clearMailboxUIAction();
    } else if (action is RefreshAllMailboxAction) {
      refreshAllMailbox();
      mailboxDashBoardController.clearMailboxUIAction();
    } else if (action is AutoCreateActionRequiredFolderMailboxAction) {
      updateMailboxTree(
        mailboxCollection: addActionRequiredFolder(
          mailboxCollection: currentMailboxCollection,
        ),
        isRefreshTrigger: false,
      );
      mailboxDashBoardController.clearMailboxUIAction();
    } else if (action is AutoRemoveActionRequiredFolderMailboxAction) {
      _onAutoRemoveActionRequiredFolderMailboxAction();
    }
  }

  void _onOpenMailboxAction(OpenMailboxAction action) {
    if (currentContext != null) {
      _handleOpenMailbox(currentContext!, action.presentationMailbox);
      if (action.presentationMailbox.role == PresentationMailbox.roleInbox) {
        _autoScrollToTopMailboxList();
      }
    }
    mailboxDashBoardController.clearMailboxUIAction();
  }

  void _onAutoRemoveActionRequiredFolderMailboxAction() {
    updateMailboxTree(
      mailboxCollection: removeActionRequiredFolder(
        mailboxCollection: currentMailboxCollection,
      ),
      isRefreshTrigger: false,
    );
    mailboxDashBoardController.clearMailboxUIAction();
    if (selectedMailbox?.isActionRequired == true) {
      _switchBackToMailboxDefault();
    }
  }

  void _handleMarkEmailsAsReadOrUnread({
    required MailboxId? affectedMailboxId,
    int? readCount,
    int? unreadCount,
  }) {
    final mailboxKey = primaryMailboxKey(affectedMailboxId);
    if (mailboxKey == null) return;

    updateUnreadCountOfMailboxByKey(
      mailboxKey,
      unreadChanges: (unreadCount ?? 0) - (readCount ?? 0),
    );
  }

  void _handleMarkMailboxAsRead({
    required MailboxId? affectedMailboxId
  }) {
    final mailboxKey = primaryMailboxKey(affectedMailboxId);
    if (mailboxKey == null) return;

    clearUnreadCount(mailboxKey);
  }

  void _handleDraftSaved({
    required MailboxId? affectedMailboxId,
    required int totalEmailsChanged,
  }) {
    final mailboxKey = primaryMailboxKey(affectedMailboxId);
    if (mailboxKey == null) return;

    updateMailboxTotalEmailsCountByKey(
      mailboxKey,
      totalEmailsChanged
    );
  }

  void _handleDeleteEmailsFromMailbox({
    required MailboxId? affectedMailboxId,
    required int totalEmailsChanged,
  }) {
    final mailboxKey = primaryMailboxKey(affectedMailboxId);
    if (mailboxKey == null) return;

    updateMailboxTotalEmailsCountByKey(
      mailboxKey,
      totalEmailsChanged
    );
  }

  void _handleMoveEmailsToMailbox({
    required Map<MailboxId, List<EmailId>> originalMailboxIdsWithEmailIds,
    required MailboxId destinationMailboxId,
    required Map<EmailId, bool> emailIdsWithReadStatus,
  }) {
    // Update changes in original mailboxes
    for (var originalMailboxIdWithEmailIds in originalMailboxIdsWithEmailIds.entries) {
      final originalMailboxId = originalMailboxIdWithEmailIds.key;
      final emailsMovedCount = originalMailboxIdWithEmailIds.value.length;
      final unreadEmailMovedCount = originalMailboxIdWithEmailIds.value
          .where((emailId) => emailIdsWithReadStatus[emailId] == false)
          .length;
      final originalMailboxKey = primaryMailboxKey(originalMailboxId);
      if (originalMailboxKey == null) continue;
      updateMailboxTotalEmailsCountByKey(
        originalMailboxKey,
        -emailsMovedCount
      );
      updateUnreadCountOfMailboxByKey(
        originalMailboxKey,
        unreadChanges: -unreadEmailMovedCount,
      );
    }

    // Update changes in destination mailbox
    final destinationMailboxKey = primaryMailboxKey(destinationMailboxId);
    if (destinationMailboxKey == null) return;
    updateMailboxTotalEmailsCountByKey(
      destinationMailboxKey,
      originalMailboxIdsWithEmailIds.entries.fold(
        0,
        (sum, entry) => sum + entry.value.length,
      ),
    );
    updateUnreadCountOfMailboxByKey(
      destinationMailboxKey,
      unreadChanges: originalMailboxIdsWithEmailIds
        .values
        .fold(
          0,
          (sum, emails) => sum + emails.where((emailId) => emailIdsWithReadStatus[emailId] == false).length,
        ),
    );
  }

  void _initWebSocketQueueHandler() {
    _webSocketQueueHandler = WebSocketQueueHandler(
      processMessageCallback: _handleWebSocketMessage,
      onErrorCallback: onError,
    );
  }

  void _initCollapseMailboxCategories() {
    if (kIsWeb && currentContext != null
        && (responsiveUtils.isMobile(currentContext!) || responsiveUtils.isTablet(currentContext!))) {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode(
          defaultMailbox: ExpandMode.COLLAPSE,
          personalFolders: ExpandMode.COLLAPSE,
          teamMailboxes: ExpandMode.COLLAPSE,);
    } else {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode.initial();
    }
  }

  Future<void> refreshAllMailbox() async {
    if (session != null && accountId != null) {
      consumeState(getAllMailboxInteractor!.execute(session!, accountId!));
      // Full re-fetch the delegated accounts so an (un)subscribe on another
      // user's mailbox is reflected. A subscription change does not advance the
      // mailbox modseq, so the Mailbox/changes based _refreshOtherUserMailboxes
      // would miss it.
      unawaited(_reloadOtherUserMailboxesInFull(session!));
    } else {
      consumeState(Stream.value(Left(GetAllMailboxFailure(NotFoundSessionException()))),);
    }
  }

  void _refreshMailboxChanges({required jmap.State newState}) {
    log('MailboxController::_refreshMailboxChanges():newState: $newState');
    if (accountId == null ||
        session == null ||
        currentMailboxState == null ||
        currentMailboxState == newState) {
      _newFolderId = null;
      return;
    }

    _webSocketQueueHandler?.enqueue(WebSocketMessage(newState: newState));
  }

  Future<void> _handleWebSocketMessage(WebSocketMessage message) async {
    try {
      final refreshViewState = await refreshAllMailboxInteractor!.execute(
        session!,
        accountId!,
        currentMailboxState!,
        properties: MailboxConstants.propertiesDefault,
      ).last;

      final refreshState = refreshViewState
          .foldSuccessWithResult<RefreshChangesAllMailboxSuccess>();

      if (refreshState is RefreshChangesAllMailboxSuccess) {
        await _handleRefreshChangeMailboxSuccess(refreshState);
        // The primary change signal is the only push this app subscribes to, so
        // opportunistically refresh the delegated accounts alongside it.
        await _refreshOtherUserMailboxes(session!);
      } else {
        _clearNewFolderId();
        if (refreshState != null) {
          onDataFailureViewState(refreshState);
        }
      }
    } catch (e, stackTrace) {
      logWarning('MailboxController::_processMailboxStateQueue:Error processing state: $e',);
      onError(e, stackTrace);
    }
    if (currentMailboxState != null) {
      _webSocketQueueHandler?.removeMessagesUpToCurrent(currentMailboxState!.value,);
    }
  }

  Future<void> _handleRefreshChangeMailboxSuccess(RefreshChangesAllMailboxSuccess success,) async {
    currentMailboxState = success.currentMailboxState;
    log('MailboxController::_handleRefreshChangeMailboxSuccess:currentMailboxState: $currentMailboxState',);
    _primaryMailboxes = success
        .mailboxList
        .listSubscribedMailboxesAndDefaultMailboxes
        .withoutVirtualMailbox;

    await _rebuildAllTrees(refreshOnly: true);

    if (_newFolderId != null) {
      _redirectToNewFolder();
    }
  }

  @override
  bool get isAINeedsActionEnabled =>
      mailboxDashBoardController.isAINeedsActionEnabled;

  /// The one place trees are rebuilt in this controller.
  ///
  /// Always composes the primary mailboxes with the cached other-user
  /// mailboxes, so neither a primary refresh nor a delayed shared load can
  /// wipe the other section. Every rebuild is followed by the same
  /// reconciliation, so the dashboard's mailbox maps and the default selection
  /// stay consistent.
  Future<void> _rebuildAllTrees({
    MailboxId? mailboxIdSelected,
    bool refreshOnly = false,
    bool selectDefaultMailbox = true,
  }) async {
    final sharedMailboxes = _otherUserAccounts.values
        .expand((account) => account.mailboxes)
        .toList();
    final composed = [..._primaryMailboxes, ...sharedMailboxes];

    if (refreshOnly) {
      await refreshTree(
        composed,
        onUpdateMailboxCollectionCallback: updateMailboxCollection,
      );
    } else {
      await buildTree(
        composed,
        mailboxIdSelected: mailboxIdSelected,
        onUpdateMailboxCollectionCallback: updateMailboxCollection,
      );
    }

    _reconcileAfterTreeBuild(selectDefaultMailbox: selectDefaultMailbox);
  }

  /// Reapplies the virtual folders onto the current collection without a full
  /// rebuild, for the paths that only need to refresh those synthetic entries.
  void _applyVirtualFoldersOnly() {
    updateMailboxTree(
      mailboxCollection: updateMailboxCollection(currentMailboxCollection),
      isRefreshTrigger: false,
    );
  }

  /// Post-build reconciliation run after every [_rebuildAllTrees].
  void _reconcileAfterTreeBuild({bool selectDefaultMailbox = true}) {
    if (currentContext != null) {
      syncAllMailboxWithDisplayName(currentContext!);
    }
    _setMapMailbox();
    _setOutboxMailbox();
    if (selectDefaultMailbox) {
      _selectSelectedMailboxDefault();
    }
    mailboxDashBoardController.refreshSpamReportBanner();
  }

  void _setMapMailbox() {
    final mapDefaultMailboxIdByRole = {
      for (var mailboxNode in defaultMailboxTree.value.root.childrenItems ?? List<MailboxNode>.empty())
        mailboxNode.item.role!: mailboxNode.item.id,
    };

    // Scoped to the primary account (plus the account-less virtual folders).
    // JMAP ids collide across accounts, so including other users' mailboxes
    // here would let one silently overwrite a primary entry and corrupt every
    // consumer that resolves a mailbox by bare id: spam/trash lookup, the
    // outbox, and email-to-mailbox resolution. Cross-account lookups use the
    // account-scoped tree instead.
    final primary = primaryAccountId;
    final mapMailboxById = {
      for (var presentationMailbox in allMailboxes)
        if (primary == null ||
            presentationMailbox.accountId == null ||
            presentationMailbox.accountId == primary)
          presentationMailbox.id: presentationMailbox,
    };

    mailboxDashBoardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole,);
    mailboxDashBoardController.setMapMailboxById(mapMailboxById);
  }

  void _setOutboxMailbox() {
    try {
      final outboxMailboxIdByRole = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleOutbox];
      if (outboxMailboxIdByRole == null) {
        final outboxMailboxByName = findNodeByNameOnFirstLevel(PresentationMailbox.outboxRole,)?.item;
        mailboxDashBoardController.setOutboxMailbox(outboxMailboxByName);
      } else {
        mailboxDashBoardController.setOutboxMailbox(mailboxDashBoardController.mapMailboxById[outboxMailboxIdByRole]!,);
      }
    } catch (e) {
      logWarning('MailboxController::_setOutboxMailbox: Not found outbox mailbox',);
      mailboxDashBoardController.setOutboxMailbox(null);
    }
  }

  void _selectSelectedMailboxDefault() {
    final isSearchEmailRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
    final dashboardRoute = mailboxDashBoardController.dashboardRoute.value;
    if (isSearchEmailRunning || dashboardRoute == DashboardRoutes.sendingQueue) {
      log('MailboxController::_selectMailboxDefault(): isSearchEmailRunning is $isSearchEmailRunning',);
      return;
    }
    final mailboxSelected = _getCurrentSelectedMailbox();
    mailboxDashBoardController.setSelectedMailbox(mailboxSelected);
  }

  PresentationMailbox? _getCurrentSelectedMailbox() {
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    final mapMailboxById = mailboxDashBoardController.mapMailboxById;
    final isSearchEmailRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
    final mapDefaultPresentationMailboxByRole = defaultMailboxTree.value.mapPresentationMailboxByRole;

    if (mailboxCurrent != null) {
      if (mailboxCurrent.hasRole()) {
        return mapDefaultPresentationMailboxByRole.containsKey(mailboxCurrent.role,)
          ? mapDefaultPresentationMailboxByRole[mailboxCurrent.role]
          : mailboxCurrent;
      } else {
        return mapMailboxById.containsKey(mailboxCurrent.id)
          ? mapMailboxById[mailboxCurrent.id]
          : mailboxCurrent;
      }
    } else if (!isSearchEmailRunning) {
      if (mapDefaultPresentationMailboxByRole.containsKey(PresentationMailbox.roleInbox,)) {
        return mapDefaultPresentationMailboxByRole[PresentationMailbox.roleInbox];
      } else if (allMailboxes.isNotEmpty) {
        return allMailboxes.first;
      }
    }

    return null;
  }

  void _handleCreateDefaultFolderIfMissing(Map<Role, MailboxId> mapDefaultMailboxRole,) {
    final listRoleMissing = MailboxConstants.defaultMailboxRoles
      .whereNot((role) => mapDefaultMailboxRole.containsKey(role) || findNodeByNameOnFirstLevel(role.value) != null,)
      .toList();

    if (listRoleMissing.isEmpty || accountId == null || session == null) {
      _applyVirtualFoldersOnly();
      return;
    }

    final mapRoles = {
      for (var role in listRoleMissing)
        Id(uuid.v1()) : role
    };
    log('MailboxController::_handleCreateDefaultFolderIfMissing():mapRoles: $mapRoles',);
    // Intentionally the primary account: default system folders are only ever
    // created for the signed-in user, never in a delegated account.
    consumeState(_createDefaultMailboxInteractor.execute(
      session!,
      accountId!,
      mapRoles),);
  }

  Future<void> _handleCreateDefaultFolderIfMissingSuccess(CreateDefaultMailboxAllSuccess success,) async {
    if (success.listMailbox.isEmpty) {
      _applyVirtualFoldersOnly();
      return;
    }

    Set<Role?> existingRoles = {};
    Set<MailboxName> existingNamesWithoutParent = {};

    final createdMailboxes = <PresentationMailbox>[];
    for (var mailbox in success.listMailbox) {
      if (mailbox.role != null && !existingRoles.add(mailbox.role)) continue;

      if (mailbox.parentId == null && mailbox.name != null && !existingNamesWithoutParent.add(mailbox.name!)) continue;

      createdMailboxes.add(mailbox.toPresentationMailbox(accountId: accountId));
    }
    _primaryMailboxes = [..._primaryMailboxes, ...createdMailboxes];

    await _rebuildAllTrees(selectDefaultMailbox: false);
  }

  void _handleDataFromNavigationRouter() {
    log('MailboxController::_handleDataFromNavigationRouter():navigationRouter: $_navigationRouter',);
    if (!PlatformInfo.isWeb || _navigationRouter == null) {
      _selectSelectedMailboxDefault();
      _replaceBrowserHistory();
      return;
    }

    if (_navigationRouter?.routeName == AppRoutes.mailtoURL) {
      mailboxDashBoardController.openComposer(
        ComposerArguments.fromMailtoUri(
          listEmailAddress: _navigationRouter?.listEmailAddress,
          cc: _navigationRouter?.cc,
          bcc: _navigationRouter?.bcc,
          subject: _navigationRouter?.subject,
          body: _navigationRouter?.body,
        ),
      );
    }

    switch(_navigationRouter!.dashboardType) {
      case DashboardType.search:
        if (_navigationRouter!.emailId != null) {
          _openEmailSearchedFromLocationBar(
            _navigationRouter!.emailId!,
            searchQuery: _navigationRouter!.searchQuery,
          );
        } else if (_navigationRouter!.searchQuery?.value.isNotEmpty == true) {
          _searchEmailFromLocationBar(_navigationRouter!.searchQuery!);
        } else {
          _clearNavigationRouter();
          _selectSelectedMailboxDefault();
          _replaceBrowserHistory();
        }
        break;
      case DashboardType.normal:
        if (_navigationRouter!.labelId != null) {
          handleLabelNavigation(_navigationRouter!, _navigationRouter!.labelId!,);
        } else if (_navigationRouter!.mailboxId != null) {
          // A delegated-account URL carries its account; a legacy bare-id URL
          // resolves against the primary account.
          final routerMailboxId = _navigationRouter!.mailboxId;
          final routerAccountId =
              _navigationRouter!.mailboxAccountId ?? primaryAccountId;
          final matchedMailboxKey =
              (routerMailboxId != null && routerAccountId != null)
                  ? MailboxKey(routerAccountId, routerMailboxId)
                  : null;
          final matchedMailboxNode = matchedMailboxKey != null
              ? findMailboxNodeByKey(matchedMailboxKey)
              : null;
          if (matchedMailboxNode != null) {
            if (_navigationRouter!.emailId != null) {
              _openEmailInsideMailboxFromLocationBar(
                matchedMailboxNode.item,
                _navigationRouter!.emailId!,
              );
            } else {
              _openMailboxFromLocationBar(matchedMailboxNode.item);
            }
          } else {
            _clearNavigationRouter();
            popAndPush(AppRoutes.unknownRoutePage);
          }
        } else if (_navigationRouter!.emailId != null) {
          _openEmailWithoutMailboxFromLocationBar(_navigationRouter!.emailId!);
        } else {
          _clearNavigationRouter();
          _selectSelectedMailboxDefault();
          _replaceBrowserHistory();
        }
        break;
    }
  }

  void openEmailInsideMailboxFromLocationBar(
    PresentationMailbox presentationMailbox,
    EmailId emailId,
  ) => _openEmailInsideMailboxFromLocationBar(presentationMailbox, emailId);

  void _openEmailInsideMailboxFromLocationBar(
    PresentationMailbox presentationMailbox,
    EmailId emailId,
  ) {
    mailboxDashBoardController.setSelectedMailbox(presentationMailbox);
    mailboxDashBoardController.dispatchAction(OpenEmailInsideMailboxFromLocationBar(emailId, presentationMailbox),);
    _clearNavigationRouter();
  }

  void openMailboxFromLocationBar(PresentationMailbox presentationMailbox) =>
      _openMailboxFromLocationBar(presentationMailbox);

  void _openMailboxFromLocationBar(PresentationMailbox presentationMailbox) {
    mailboxDashBoardController.setSelectedMailbox(presentationMailbox);
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: presentationMailbox.browserRouteTitle,
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: presentationMailbox.browserRouteMailboxId,
            labelId: presentationMailbox.labelId,
            dashboardType: DashboardType.normal,
          ),
        ),
      );
    }
    _clearNavigationRouter();
  }

  void _openEmailWithoutMailboxFromLocationBar(EmailId emailId) {
    mailboxDashBoardController.dispatchAction(
      OpenEmailWithoutMailboxFromLocationBar(emailId),
    );
    _clearNavigationRouter();
  }

  void _openEmailSearchedFromLocationBar(
    EmailId emailId,
    {
      SearchQuery? searchQuery,
    }
  ) {
    mailboxDashBoardController.dispatchAction(
      OpenEmailSearchedFromLocationBar(
        emailId,
        searchQuery: searchQuery),
    );
    _clearNavigationRouter();
  }

  void _searchEmailFromLocationBar(SearchQuery searchQuery) {
    mailboxDashBoardController.dispatchAction(
      SearchEmailFromLocationBar(searchQuery),
    );
    _clearNavigationRouter();
  }

  void clearNavigationRouter() => _clearNavigationRouter();

  void _clearNavigationRouter() {
    _navigationRouter = null;
  }

  void _handleOpenMailbox(
    BuildContext context,
    PresentationMailbox presentationMailboxSelected,
  ) {
    log('MailboxController::_handleOpenMailbox():MAILBOX_ID = ${presentationMailboxSelected.id.asString} | MAILBOX_NAME: ${presentationMailboxSelected.name?.name}',);
    KeyboardUtils.hideKeyboard(context);
    mailboxDashBoardController.clearSelectedEmail();
    if (presentationMailboxSelected.id != mailboxDashBoardController.selectedMailbox.value?.id) {
      mailboxDashBoardController.clearFilterMessageOption();
    }
    _disableAllSearchEmail();
    mailboxDashBoardController.closeMailboxMenuDrawer();
    mailboxDashBoardController.setSelectedMailbox(presentationMailboxSelected);
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    _replaceBrowserHistory();
  }

  void _disableAllSearchEmail() {
    mailboxDashBoardController.dispatchAction(ClearAllFieldOfAdvancedSearchAction(),);
    mailboxDashBoardController.searchController.disableAllSearchEmail();
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected,
  ) {
    _openMailboxEventController.add(OpenMailboxViewEvent(context, presentationMailboxSelected),);
  }

  void goToCreateNewMailboxView(BuildContext context, {PresentationMailbox? parentMailbox,}) async {
    // A subfolder is created in its parent's account; a top-level folder in the
    // primary account.
    final currentSession = session;
    final targetAccountId =
        parentMailbox != null ? accountIdOf(parentMailbox) : primaryAccountId;
    if (currentSession != null && targetAccountId != null) {
      final arguments = MailboxCreatorArguments(
        allMailboxes.withoutVirtualMailbox,
        parentMailbox,
      );

      final result = PlatformInfo.isWeb
        ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.mailboxCreator, arguments: arguments,)
        : await push(AppRoutes.mailboxCreator, arguments: arguments);

      if (result != null && result is NewMailboxArguments) {
        _createNewMailboxAction(
          currentSession,
          targetAccountId,
          CreateNewMailboxRequest(
            result.newName,
            parentId: result.mailboxLocation?.id,
          ),
        );
      }
    }
  }

  void _createNewMailboxAction(Session session, AccountId accountId, CreateNewMailboxRequest request,) async {
    consumeState(_createNewMailboxInteractor.execute(session, accountId, request),);
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!,).createFolderSuccessfullyMessage(success.newMailbox.name?.name ?? ''),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,);

      _newFolderId = success.newMailbox.id;
    }
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!,).createNewFolderFailure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).createNewFolderFailure;
      }
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void _renameMailboxSuccess(RenameMailboxSuccess success) {
    final mailboxKey = primaryMailboxKey(success.request.mailboxId);
    if (mailboxKey == null) return;
    updateMailboxNameByKey(mailboxKey, success.request.newName);
  }

  void _renameMailboxFailure(RenameMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!,).renameFolderFailure;
      if (exception is EmptyMailboxNameException) {
        messageError = AppLocalizations.of(currentContext!,).nameOfFolderIsRequired;
      } else if (exception is ContainsInvalidCharactersMailboxNameException) {
        messageError = AppLocalizations.of(currentContext!,).folderNameCannotContainSpecialCharacters;
      }
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void openSearchViewAction(BuildContext context) {
    if (PlatformInfo.isWeb) {
      SearchMailboxBindings().dependencies();
      mailboxDashBoardController.searchMailboxActivated.value = true;
    } else {
      push(AppRoutes.searchMailbox);
    }
    closeMailboxScreen(context);
  }

  List<MailboxActions> get listActionOfMailboxSelected {
    final currentMailboxesSelected = listMailboxSelected;

    if (currentMailboxesSelected.length == 1) {
      if (currentMailboxesSelected.isAllDefaultMailboxes && currentMailboxesSelected.isAllUnreadMailboxes) {
        return [MailboxActions.markAsRead];
      } else if (currentMailboxesSelected.isAllPersonalMailboxes) {
        return [
          MailboxActions.move,
          MailboxActions.rename,
          if (currentMailboxesSelected.isAllUnreadMailboxes)
            MailboxActions.markAsRead,
          MailboxActions.delete,
        ];
      } else {
        return [];
      }
    } else if (currentMailboxesSelected.length > 1
      && currentMailboxesSelected.isAllPersonalMailboxes) {
      return [MailboxActions.delete];
    } else {
      return [];
    }
  }

  List<PresentationMailbox> get listMailboxSelected {
    final defaultMailboxSelected = defaultMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE,);

    final folderMailboxSelected = personalMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE,);

    final teamMailboxesSelected = teamMailboxesTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE,);

    return [
      defaultMailboxSelected,
      folderMailboxSelected,
      teamMailboxesSelected,
    ]
      .expand((node) => node)
      .map((node) => node.item)
      .toList();
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    final ctx = requestContextOf(presentationMailbox);
    if (ctx != null) {
      consumeState(_deleteMultipleMailboxInteractor.execute(
        ctx.session,
        ctx.accountId,
        [presentationMailbox.id,]),);
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    popBack();
  }

  void _deleteMultipleMailboxSuccess(
      List<MailboxId> listMailboxIdDeleted,
      jmap.State? currentMailboxState,
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteFoldersSuccessfully,);
    }

    if (listMailboxIdDeleted.contains(selectedMailbox?.id)) {
      _switchBackToMailboxDefault();
      _closeEmailViewIfMailboxDisabledOrNotExist(listMailboxIdDeleted);
    }
  }

  void _switchBackToMailboxDefault() {
    final inboxMailbox = findMailboxNodeByRole(PresentationMailbox.roleInbox);
    mailboxDashBoardController.setSelectedMailbox(inboxMailbox?.item);
    _replaceBrowserHistory();
    _autoScrollToTopMailboxList();
  }

  void _deleteMailboxFailure(DeleteMultipleMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteFoldersFailure,
        leadingSVGIcon: imagePaths.icDeleteToast,
      );
    }
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, MailboxName newMailboxName,) {
    final ctx = requestContextOf(presentationMailbox);
    if (ctx != null) {
      consumeState(_renameMailboxInteractor.execute(
        ctx.session,
        ctx.accountId,
        RenameMailboxRequest(presentationMailbox.id, newMailboxName),
        ),
      );
    }
  }

  void _handleMovingMailbox(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveAction moveAction,
    PresentationMailbox mailboxSelected,
    {PresentationMailbox? destinationMailbox,}
  ) {
    consumeState(_moveMailboxInteractor.execute(
      session,
      accountId,
      MoveMailboxRequest(
        mailboxSelected.id,
        moveAction,
        destinationMailboxId: destinationMailbox?.id,
        destinationMailboxDisplayName: destinationMailbox?.getDisplayName(context,),
        parentId: mailboxSelected.parentId,
        ),
      ),);
  }

  void _moveMailboxSuccess(MoveMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving
        && currentOverlayContext != null
        && currentContext != null) {
      appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).movedToFolder(
              success.destinationMailboxDisplayName ?? AppLocalizations.of(currentContext!).allFolders,),
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            _undoMovingMailbox(MoveMailboxRequest(
                success.mailboxIdSelected,
                MoveAction.undo,
                destinationMailboxId: success.parentId,
                parentId: success.destinationMailboxId,
            ),);
          },
          leadingSVGIcon: imagePaths.icFolderMailbox,
          leadingSVGIconColor: Colors.white,
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          actionIcon: SvgPicture.asset(imagePaths.icUndo),);
    }
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    // A move never crosses accounts, so the undo runs against the same account
    // that owns the moved mailbox.
    final currentSession = session;
    final owningAccountId =
        _accountIdOfMailboxId(newMoveRequest.mailboxId) ?? primaryAccountId;
    if (currentSession != null && owningAccountId != null) {
      consumeState(_moveMailboxInteractor.execute(
        currentSession,
        owningAccountId,
        newMoveRequest),);
    }
  }

  /// Resolves the owning account of a mailbox already placed in a tree, by id.
  AccountId? _accountIdOfMailboxId(MailboxId mailboxId) {
    for (final mailboxTree in allMailboxTrees) {
      final node =
          mailboxTree.value.findNode((node) => node.item.id == mailboxId);
      if (node != null) return node.item.accountId ?? primaryAccountId;
    }
    return null;
  }

  void _handleNavigationRouteParameters(Map<String, dynamic>? parameters) {
    log('MailboxController::_handleNavigationRouteParameters(): parameters: $parameters',);
    if (parameters != null) {
      final navigationRouter = RouteUtils.parsingRouteParametersToNavigationRouter(parameters);
      log('MailboxController::_handleNavigationRouteParameters():navigationRouter: $navigationRouter',);
      _navigationRouter = navigationRouter;
    }
  }

  void handleMailboxAction(
      BuildContext context,
      MailboxActions actions,
      PresentationMailbox mailbox,
  ) {
    switch(actions) {
      case MailboxActions.delete:
        openConfirmationDialogDeleteMailboxAction(
          context,
          responsiveUtils,
          imagePaths,
          mailbox,
          onDeleteMailboxAction: _deleteMailboxAction,
        );
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          mailbox,
          responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction,
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onMovingMailboxAction: (mailboxSelected, destinationMailbox) => _invokeMovingMailboxAction(context, mailboxSelected, destinationMailbox,
          ),
        );
        break;
      case MailboxActions.markAsRead:
      case MailboxActions.confirmMailSpam:
        markAsReadMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onCallbackAction: closeMailboxScreen,
        );
        break;
      case MailboxActions.openInNewTab:
        openMailboxInNewTabAction(mailbox);
        break;
      case MailboxActions.copySubaddress:
        try{
          final subaddress = getSubAddress(
            mailboxDashBoardController.ownEmailAddress.value,
            findNodePathWithSeparator(mailbox.key, '.')!,
          );
          copySubAddressAction(context, subaddress);
        } catch (error) {
          appToast.showToastErrorMessage(context, AppLocalizations.of(context).errorWhileFetchingSubaddress,);
        }
        break;
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        mailboxDashBoardController.storeSpamReportStateAction();
        break;
      case MailboxActions.disableMailbox:
        _unsubscribeMailboxAction(mailbox.key);
        break;
      case MailboxActions.allowSubaddressing:
        try{
          final subAddress = getSubAddress(
            mailboxDashBoardController.ownEmailAddress.value,
            findNodePathWithSeparator(mailbox.key, '.')!,
          );
          openConfirmationDialogSubAddressingAction(
              context,
              mailbox.id,
              mailbox.getDisplayName(context),
              subAddress,
              mailbox.rights,
              onAllowSubAddressingAction: _handleSubaddressingAction,
          );
        } catch (error) {
          appToast.showToastErrorMessage(context, AppLocalizations.of(context).errorWhileFetchingSubaddress,);
        }
        break;
      case MailboxActions.disallowSubaddressing:
        _handleSubaddressingAction(mailbox.id, mailbox.rights, actions);
        break;
      case MailboxActions.emptyTrash:
        emptyTrashAction(context, mailbox, mailboxDashBoardController);
        break;
      case MailboxActions.emptySpam:
        emptySpamAction(context, mailbox, mailboxDashBoardController);
        break;
      case MailboxActions.newSubfolder:
        goToCreateNewMailboxView(context, parentMailbox: mailbox);
        break;
      case MailboxActions.createFilter:
        mailboxDashBoardController.openCreateEmailRuleView(
          presentationMailbox: mailbox,
        );
        break;
      case MailboxActions.recoverDeletedMessages:
        mailboxDashBoardController.gotoEmailRecovery();
        break;
      case MailboxActions.moveFolderContent:
        performMoveFolderContent(
          context: context,
          mailboxSelected: mailbox,
          mailboxActionReactor: mailboxActionReactor,
          dashboardController: mailboxDashBoardController,
          baseMailboxController: this,
        );
        mailboxDashBoardController.closeMailboxMenuDrawer();
        break;
      default:
        break;
    }
  }

  void _invokeMovingMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    PresentationMailbox? destinationMailbox,
  ) {
    final ctx = requestContextOf(mailboxSelected);
    if (ctx == null) return;

    // A cross-account move would need Email/copy plus destroy, which this app
    // does not implement, so reject it rather than silently move within the
    // wrong account.
    if (destinationMailbox != null &&
        accountIdOf(destinationMailbox) != ctx.accountId) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).moveMailboxAcrossAccountsNotSupported,
        );
      }
      return;
    }

    _handleMovingMailbox(
      context,
      ctx.session,
      ctx.accountId,
      MoveAction.moving,
      mailboxSelected,
      destinationMailbox: destinationMailbox,
    );
  }

  void _replaceBrowserHistory() {
    final currentMailbox = selectedMailbox;
    log('MailboxController::_replaceBrowserHistory:selectedMailbox: ${currentMailbox?.id.asString}',);
    if (PlatformInfo.isWeb && Get.currentRoute.startsWith(AppRoutes.dashboard)) {
      final route = RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          mailboxId: currentMailbox?.browserRouteMailboxId,
          // Carry the account only for a delegated mailbox, so primary-account
          // URLs stay unchanged.
          mailboxAccountId:
              currentMailbox != null && isOtherUserMailbox(currentMailbox)
                  ? currentMailbox.accountId
                  : null,
          labelId: currentMailbox?.labelId,
          searchQuery: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? mailboxDashBoardController.searchController.searchQuery
            : null,
          dashboardType: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? DashboardType.search
            : DashboardType.normal,
        ),
      );
      RouteUtils.replaceBrowserHistory(
        title: currentMailbox?.browserRouteTitle ?? '',
        url: route,
      );
    }
  }

  void closeMailboxScreen(BuildContext context) {
    mailboxDashBoardController.closeMailboxMenuDrawer();
  }

  void autoScrollTop() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear,);
  }

  void autoScrollBottom() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear,);
  }

  void stopAutoScroll() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,);
  }

  Future<void> _handleGetAllMailboxSuccess(GetAllMailboxSuccess success) async {
    currentMailboxState = success.currentMailboxState;
    log('MailboxController::_handleGetAllMailboxSuccess:currentMailboxState: $currentMailboxState',);
    _primaryMailboxes = success
        .mailboxList
        .listSubscribedMailboxesAndDefaultMailboxes
        .withoutVirtualMailbox;
    // onDone -> _handleDataFromNavigationRouter owns the selection here, so this
    // path must not pick the default itself or it flashes Inbox before the
    // location-bar mailbox is selected.
    await _rebuildAllTrees(selectDefaultMailbox: false);
  }

  Future<void> _updateMailboxIdsBlockNotificationToKeychain(List<PresentationMailbox> mailboxes,) async {
    // Intentionally the primary account: the iOS keychain is keyed on the
    // signed-in account, so only its mailboxes are stored.
    _iosSharingManager = getBinding<IOSSharingManager>();
    if (accountId == null || _iosSharingManager == null || mailboxes.isEmpty) {
      logWarning('MailboxController::_updateMailboxIdsBlockNotificationToKeychain: AccountId = $accountId | IosSharingManager = $_iosSharingManager | Mailboxes = ${mailboxes.length}',);
      return;
    }

    if (await _iosSharingManager!.isExistMailboxIdsBlockNotificationInKeyChain(accountId!,)) {
      return;
    }

    final mailboxIdsBlockNotification = mailboxes
      .where((presentationMailbox) => presentationMailbox.pushNotificationDeactivated && presentationMailbox.mailboxId != null,)
      .map((presentationMailbox) => presentationMailbox.mailboxId!)
      .toList();
    log('MailboxController::_updateMailboxIdsBlockNotificationToKeychain:MailboxIdsBlockNotification = $mailboxIdsBlockNotification',);
    _iosSharingManager!.updateMailboxIdsBlockNotificationInKeyChain(
      accountId: accountId!,
      mailboxIds: mailboxIdsBlockNotification,);
  }

  void _unsubscribeMailboxAction(MailboxKey mailboxKey) {
    final currentSession = session;
    // The key already carries the owning account, so unsubscribe runs against
    // the account that owns the mailbox.
    final owningAccountId = mailboxKey.accountId;
    if (currentSession != null) {
      final subscribeRequest = generateSubscribeRequest(
        mailboxKey,
        MailboxSubscribeState.disabled,
        MailboxSubscribeAction.unSubscribe,
      );

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(
          currentSession,
          owningAccountId,
          subscribeRequest,
        ),);
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(
          currentSession,
          owningAccountId,
          subscribeRequest,
        ),);
      }
    }
  }

  void _handleUnsubscribeMailboxSuccess(SubscribeMailboxSuccess success) {
    if (success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(success.mailboxId);

      if (success.mailboxId == selectedMailbox?.id) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist([success.mailboxId]);
      }
    }
  }

  void _handleUnsubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess success,) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe,
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }
  }

  void _handleUnsubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess success,) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe,
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }
  }

  void _closeEmailViewIfMailboxDisabledOrNotExist(List<MailboxId> mailboxIdsDisabled,) {
    if (selectedEmail == null) {
      return;
    }

    final mailboxContain = selectedEmail!.findMailboxContain(mailboxDashBoardController.mapMailboxById,);
    if (mailboxContain != null && mailboxIdsDisabled.contains(mailboxContain.id)) {
      mailboxDashBoardController.clearSelectedEmail();
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      {List<MailboxId>? listDescendantMailboxIds,}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideFolderSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _undoUnsubscribeMailboxAction(
          mailboxIdSubscribed,
          listDescendantMailboxIds: listDescendantMailboxIds,
        ),
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),);
    }
  }

  void _undoUnsubscribeMailboxAction(
    MailboxId mailboxIdSubscribed,
    {List<MailboxId>? listDescendantMailboxIds,}
  ) {
    final currentSession = session;
    // Re-subscribe runs against the account that owns the mailbox.
    final owningAccountId =
        _accountIdOfMailboxId(mailboxIdSubscribed) ?? primaryAccountId;
    if (currentSession != null && owningAccountId != null) {
      SubscribeRequest? subscribeRequest;

      if (listDescendantMailboxIds != null) {
        subscribeRequest = SubscribeMultipleMailboxRequest(
          mailboxIdSubscribed,
          listDescendantMailboxIds,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo,
        );
      } else {
        subscribeRequest = SubscribeMailboxRequest(
          mailboxIdSubscribed,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo,
        );
      }

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(
          currentSession,
          owningAccountId,
          subscribeRequest,
        ),);
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(
          currentSession,
          owningAccountId,
          subscribeRequest,
        ),);
      }
    }
  }

  void _handleSubaddressingAction(MailboxId mailboxId, Map<String, List<String>?>? currentRights, MailboxActions subaddressingAction,) {
    // Sub-addressing runs against the account that owns the mailbox, not the
    // signed-in account.
    final owningAccountId =
        _accountIdOfMailboxId(mailboxId) ?? primaryAccountId;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && owningAccountId != null) {
      final allowSubaddressingRequest = MailboxRightRequest(
          mailboxId,
          currentRights,
          subaddressingAction == MailboxActions.allowSubaddressing ? MailboxSubaddressingAction.allow : MailboxSubaddressingAction.disallow,
      );

      consumeState(_subaddressingInteractor.execute(session, owningAccountId, allowSubaddressingRequest,
        ),);
    } else {
      handleSubAddressingFailure(
        SubaddressingFailure.withException(const NullSessionOrAccountIdException(),),
      );
    }

    popBack();
  }

  void _mailboxListScrollControllerListener() {
    _handleScrollTop();
    _handleScrollBottom();
  }

  void _handleScrollTop() {
    if (mailboxListScrollController.position.pixels == 0) {
      _activeScrollTop.value = false;
    }

    if (mailboxListScrollController.position.pixels > 40) {
      _activeScrollTop.value = true;
    }
  }

  void _handleScrollBottom() {
    if (mailboxListScrollController.position.pixels - mailboxListScrollController.position.maxScrollExtent == 0) {
      _activeScrollBottom.value = false;
    }

    if (mailboxListScrollController.position.maxScrollExtent - mailboxListScrollController.position.pixels > 40) {
      _activeScrollBottom.value = true;
    }
  }

  bool get activeScrollTop => _activeScrollTop.value;

  bool get activeScrollBottom => _activeScrollBottom.value;

  void openSendingQueueViewAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    _disableAllSearchEmail();
    mailboxDashBoardController.clearSelectedEmail();
    mailboxDashBoardController.clearFilterMessageOption();
    mailboxDashBoardController.setSelectedMailbox(null);
    closeMailboxScreen(context);
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.sendingQueue);
  }

  void _clearNewFolderId() {
    _newFolderId = null;
  }

  void _redirectToNewFolder() {
    final newFolderKey = primaryMailboxKey(_newFolderId);
    final newMailboxNode =
        newFolderKey != null ? findMailboxNodeByKey(newFolderKey) : null;
    log('MailboxController::_redirectToNewFolder:newMailboxNode: $newMailboxNode',);
    if (newMailboxNode != null && currentContext != null) {
      _handleOpenMailbox(currentContext!, newMailboxNode.item);
    }
    _clearNewFolderId();
  }

  void _autoScrollToTopMailboxList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mailboxListScrollController.hasClients){
        mailboxListScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void emptyMailboxAction(BuildContext context, PresentationMailbox presentationMailbox,) {
    log('MailboxController::emptyMailboxAction:presentationMailbox: ${presentationMailbox.name}',);
    if (presentationMailbox.isTrash) {
      mailboxDashBoardController.emptyTrashFolderAction(
        trashMailbox: presentationMailbox,
      );
    } else if (presentationMailbox.isSpam) {
      mailboxDashBoardController.emptySpamFolderAction(
        spamFolderId: presentationMailbox.id,
        totalEmails: presentationMailbox.countTotalEmails,
      );
    }
  }
}