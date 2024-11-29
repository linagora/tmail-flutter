import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
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
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/constants/mailbox_constants.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/empty_folder_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/invalid_mail_format_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/null_session_or_accountid_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
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
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subaddressing_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/open_mailbox_view_event.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class MailboxController extends BaseMailboxController
    with MailboxActionHandlerMixin, ContactSupportMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final isMailboxListScrollable = false.obs;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;
  final SubscribeMailboxInteractor _subscribeMailboxInteractor;
  final SubscribeMultipleMailboxInteractor _subscribeMultipleMailboxInteractor;
  final SubaddressingInteractor _subaddressingInteractor;
  final CreateDefaultMailboxInteractor _createDefaultMailboxInteractor;

  IOSSharingManager? _iosSharingManager;

  final currentSelectMode = SelectMode.INACTIVE.obs;
  final _activeScrollTop = RxBool(false);
  final _activeScrollBottom = RxBool(true);

  MailboxId? _newFolderId;
  NavigationRouter? _navigationRouter;
  WebSocketQueueHandler? _webSocketQueueHandler;

  final _openMailboxEventController = StreamController<OpenMailboxViewEvent>();
  final mailboxListScrollController = ScrollController();

  PresentationMailbox? get selectedMailbox => mailboxDashBoardController.selectedMailbox.value;

  PresentationEmail? get selectedEmail => mailboxDashBoardController.selectedEmail.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

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
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor  refreshAllMailboxInteractor,
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    _initWebSocketQueueHandler();
    super.onInit();
  }

  @override
  void onReady() {
    _openMailboxEventController.stream.debounceTime(const Duration(milliseconds: 500)).listen((event) {
      _handleOpenMailbox(event.buildContext, event.presentationMailbox);
    });
    _initCollapseMailboxCategories();
    mailboxListScrollController.addListener(_mailboxListScrollControllerListener);
    super.onReady();
  }

  @override
  void onClose() {
    _openMailboxEventController.close();
    mailboxListScrollController.dispose();
    _webSocketQueueHandler?.dispose();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess) {
      _handleGetAllMailboxSuccess(success);
    } else if (success is CreateNewMailboxSuccess) {
      _createNewMailboxSuccess(success);
    } else if (success is DeleteMultipleMailboxAllSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
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
      _handleSubaddressingSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is CreateNewMailboxFailure) {
      _createNewMailboxFailure(failure);
    } else if (failure is RenameMailboxFailure) {
      _renameMailboxFailure(failure);
    } else if (failure is DeleteMultipleMailboxFailure) {
      _deleteMailboxFailure(failure);
    } else if (failure is SubaddressingFailure) {
      _handleSubaddressingFailure(failure);
    }
  }

  @override
  void onDone() {
    super.onDone();
    viewState.value.fold(
      (failure) {
        if (failure is GetAllMailboxFailure) {
          mailboxDashBoardController.updateRefreshAllMailboxState(Left(RefreshAllMailboxFailure()));
        }
      },
      (success) {
        if (success is GetAllMailboxSuccess) {
          mailboxDashBoardController.updateRefreshAllMailboxState(Right(RefreshAllMailboxSuccess()));
          _handleCreateDefaultFolderIfMissing(mailboxDashBoardController.mapDefaultMailboxIdByRole);
          _handleDataFromNavigationRouter();
          mailboxDashBoardController.getSpamReportBanner();
          if (PlatformInfo.isIOS) {
            _updateMailboxIdsBlockNotificationToKeychain(success.mailboxList);
          }
        }
      });
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId != null && session != null) {
        getAllMailbox(session!, accountId);
      }
    });

    ever<Map<String, dynamic>?>(
      mailboxDashBoardController.routerParameters,
      _handleNavigationRouteParameters
    );

    ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is ClearSearchEmailAction) {
        _switchBackToMailboxDefault();
      }
    });

    ever(mailboxDashBoardController.mailboxUIAction, (action) {
      if (action is SelectMailboxDefaultAction) {
        _switchBackToMailboxDefault();
        mailboxDashBoardController.clearMailboxUIAction();
      } else if (action is RefreshChangeMailboxAction) {
        _refreshMailboxChanges(newState: action.newState);
      } else if (action is OpenMailboxAction) {
        if (currentContext != null) {
          _handleOpenMailbox(currentContext!, action.presentationMailbox);
          if (action.presentationMailbox.role == PresentationMailbox.roleInbox) {
            _autoScrollToTopMailboxList();
          }
        }
        mailboxDashBoardController.clearMailboxUIAction();
      } else if (action is SystemBackToInboxAction) {
        _disableAllSearchEmail();
        _switchBackToMailboxDefault();
        mailboxDashBoardController.clearMailboxUIAction();
      } else if (action is RefreshAllMailboxAction) {
        refreshAllMailbox();
        mailboxDashBoardController.clearMailboxUIAction();
      }
    });

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
          affectedMailboxId: reactionState.mailboxId,
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
      }
    });
  }

  void _handleMarkEmailsAsReadOrUnread({
    required MailboxId? affectedMailboxId,
    int? readCount,
    int? unreadCount,
  }) {
    if (affectedMailboxId == null) return;

    updateUnreadCountOfMailboxById(
      affectedMailboxId,
      unreadChanges: (unreadCount ?? 0) - (readCount ?? 0),
    );
  }

  void _handleMarkMailboxAsRead({
    required MailboxId? affectedMailboxId,
  }) {
    if (affectedMailboxId == null) return;

    clearUnreadCount(affectedMailboxId);
  }

  void _handleDraftSaved({
    required MailboxId? affectedMailboxId,
    required int totalEmailsChanged,
  }) {
    if (affectedMailboxId == null) return;

    updateMailboxTotalEmailsCountById(
      affectedMailboxId,
      totalEmailsChanged,
    );
  }

  void _handleDeleteEmailsFromMailbox({
    required MailboxId? affectedMailboxId,
    required int totalEmailsChanged,
  }) {
    if (affectedMailboxId == null) return;

    updateMailboxTotalEmailsCountById(
      affectedMailboxId,
      totalEmailsChanged,
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
      updateMailboxTotalEmailsCountById(
        originalMailboxId,
        -emailsMovedCount,
      );
      updateUnreadCountOfMailboxById(
        originalMailboxId,
        unreadChanges: -unreadEmailMovedCount,
      );
    }

    // Update changes in destination mailbox
    updateMailboxTotalEmailsCountById(
      destinationMailboxId,
      originalMailboxIdsWithEmailIds.entries.fold(
        0,
        (sum, entry) => sum + entry.value.length,
      ),
    );
    updateUnreadCountOfMailboxById(
      destinationMailboxId,
      unreadChanges: originalMailboxIdsWithEmailIds
        .values
        .fold(
          0,
          (sum, emails) => sum + emails.where((emailId) => emailIdsWithReadStatus[emailId] == false).length
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
          teamMailboxes: ExpandMode.COLLAPSE);
    } else {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode.initial();
    }
  }

  Future<void> refreshAllMailbox() async {
    if (session != null && accountId != null) {
      consumeState(getAllMailboxInteractor!.execute(session!, accountId!));
    } else {
      consumeState(Stream.value(Left(GetAllMailboxFailure(NotFoundSessionException()))));
    }
  }
  
  void _refreshMailboxChanges({jmap.State? newState}) {
    log('MailboxController::_refreshMailboxChanges():newState: $newState');
    if (accountId == null ||
        session == null ||
        currentMailboxState == null ||
        newState == null) {
      _newFolderId = null;
      return;
    }

    _webSocketQueueHandler?.enqueue(WebSocketMessage(newState: newState));
  }

  Future<void> _handleWebSocketMessage(WebSocketMessage message) async {
    try {
      if (currentMailboxState == message.newState) {
        log('MailboxController::_handleWebSocketMessage:Skipping redundant state: ${message.newState}');
        return Future.value();
      }

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
      } else {
        _clearNewFolderId();
        onDataFailureViewState(refreshState);
      }
    } catch (e, stackTrace) {
      logError('MailboxController::_processMailboxStateQueue:Error processing state: $e');
      onError(e, stackTrace);
    }
    if (currentMailboxState != null) {
      _webSocketQueueHandler?.removeMessagesUpToCurrent(currentMailboxState!.value);
    }
  }

  Future<void> _handleRefreshChangeMailboxSuccess(RefreshChangesAllMailboxSuccess success) async {
    currentMailboxState = success.currentMailboxState;
    log('MailboxController::_handleRefreshChangeMailboxSuccess:currentMailboxState: $currentMailboxState');
    final listMailboxDisplayed = success
        .mailboxList
        .listSubscribedMailboxesAndDefaultMailboxes;

    await refreshTree(listMailboxDisplayed);

    if (currentContext != null) {
      syncAllMailboxWithDisplayName(currentContext!);
    }
    _setMapMailbox();
    _setOutboxMailbox();
    _selectSelectedMailboxDefault();
    mailboxDashBoardController.refreshSpamReportBanner();

    if (_newFolderId != null) {
      _redirectToNewFolder();
    }
  }

  void _setMapMailbox() {
    final mapDefaultMailboxIdByRole = {
      for (var mailboxNode in defaultMailboxTree.value.root.childrenItems ?? List<MailboxNode>.empty())
        mailboxNode.item.role!: mailboxNode.item.id
    };

    final mapMailboxById = {
      for (var presentationMailbox in allMailboxes)
        presentationMailbox.id: presentationMailbox
    };

    mailboxDashBoardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
    mailboxDashBoardController.setMapMailboxById(mapMailboxById);
  }

  void _setOutboxMailbox() {
    try {
      final outboxMailboxIdByRole = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleOutbox];
      if (outboxMailboxIdByRole == null) {
        final outboxMailboxByName = findNodeByNameOnFirstLevel(PresentationMailbox.outboxRole)?.item;
        mailboxDashBoardController.setOutboxMailbox(outboxMailboxByName);
      } else {
        mailboxDashBoardController.setOutboxMailbox(mailboxDashBoardController.mapMailboxById[outboxMailboxIdByRole]!);
      }
    } catch (e) {
      logError('MailboxController::_setOutboxMailbox: Not found outbox mailbox');
      mailboxDashBoardController.setOutboxMailbox(null);
    }
  }

  void _selectSelectedMailboxDefault() {
    final isSearchEmailRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
    final dashboardRoute = mailboxDashBoardController.dashboardRoute.value;
    if (isSearchEmailRunning || dashboardRoute == DashboardRoutes.sendingQueue) {
      log('MailboxController::_selectMailboxDefault(): isSearchEmailRunning is $isSearchEmailRunning');
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
        return mapDefaultPresentationMailboxByRole.containsKey(mailboxCurrent.role)
          ? mapDefaultPresentationMailboxByRole[mailboxCurrent.role]
          : mailboxCurrent;
      } else {
        return mapMailboxById.containsKey(mailboxCurrent.id)
          ? mapMailboxById[mailboxCurrent.id]
          : mailboxCurrent;
      }
    } else if (!isSearchEmailRunning) {
      if (mapDefaultPresentationMailboxByRole.containsKey(PresentationMailbox.roleInbox)) {
        return mapDefaultPresentationMailboxByRole[PresentationMailbox.roleInbox];
      } else if (allMailboxes.isNotEmpty) {
        return allMailboxes.first;
      }
    }

    return null;
  }

  void _handleCreateDefaultFolderIfMissing(Map<Role, MailboxId> mapDefaultMailboxRole) {
    final listRoleMissing = MailboxConstants.defaultMailboxRoles
      .whereNot((role) => mapDefaultMailboxRole.containsKey(role) || findNodeByNameOnFirstLevel(role.value) != null)
      .toList();
    log('MailboxController::_handleCreateDefaultFolderIfMissing():listRoleMissing: $listRoleMissing');
    if (listRoleMissing.isNotEmpty && accountId != null && session != null) {
      consumeState(_createDefaultMailboxInteractor.execute(
        session!,
        accountId!,
        listRoleMissing
      ));
    }
  }

  void _handleDataFromNavigationRouter() {
    log('MailboxController::_handleDataFromNavigationRouter():navigationRouter: $_navigationRouter');
    if (!PlatformInfo.isWeb || _navigationRouter == null) {
      _selectSelectedMailboxDefault();
      _replaceBrowserHistory();
      return;
    }

    if (_navigationRouter?.routeName == AppRoutes.mailtoURL) {
      mailboxDashBoardController.goToComposer(
        ComposerArguments.fromMailtoUri(
          listEmailAddress: _navigationRouter?.listEmailAddress,
          cc: _navigationRouter?.cc,
          bcc: _navigationRouter?.bcc,
          subject: _navigationRouter?.subject,
          body: _navigationRouter?.body
        )
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
        if (_navigationRouter!.mailboxId != null) {
          final matchedMailboxNode = findMailboxNodeById(_navigationRouter!.mailboxId!);
          if (matchedMailboxNode != null) {
            if (_navigationRouter!.emailId != null) {
              _openEmailInsideMailboxFromLocationBar(
                matchedMailboxNode.item,
                _navigationRouter!.emailId!
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

  void _openEmailInsideMailboxFromLocationBar(
    PresentationMailbox presentationMailbox,
    EmailId emailId
  ) {
    mailboxDashBoardController.setSelectedMailbox(presentationMailbox);
    mailboxDashBoardController.dispatchAction(OpenEmailInsideMailboxFromLocationBar(emailId, presentationMailbox));
    _clearNavigationRouter();
  }

  void _openMailboxFromLocationBar(PresentationMailbox presentationMailbox) {
    mailboxDashBoardController.setSelectedMailbox(presentationMailbox);
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: 'Mailbox-${presentationMailbox.mailboxId?.id.value}',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: presentationMailbox.mailboxId,
            dashboardType: DashboardType.normal
          )
        )
      );
    }
    _clearNavigationRouter();
  }

  void _openEmailWithoutMailboxFromLocationBar(EmailId emailId) {
    mailboxDashBoardController.dispatchAction(
      OpenEmailWithoutMailboxFromLocationBar(emailId)
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
        searchQuery: searchQuery,
      )
    );
    _clearNavigationRouter();
  }

  void _searchEmailFromLocationBar(SearchQuery searchQuery) {
    mailboxDashBoardController.dispatchAction(
      SearchEmailFromLocationBar(searchQuery)
    );
    _clearNavigationRouter();
  }

  void _clearNavigationRouter() {
    _navigationRouter = null;
  }

  void _handleOpenMailbox(
    BuildContext context,
    PresentationMailbox presentationMailboxSelected
  ) {
    log('MailboxController::_handleOpenMailbox():MAILBOX_ID = ${presentationMailboxSelected.id.asString} | MAILBOX_NAME: ${presentationMailboxSelected.name?.name}');
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
    mailboxDashBoardController.dispatchAction(ClearAllFieldOfAdvancedSearchAction());
    mailboxDashBoardController.searchController.disableAllSearchEmail();
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    _openMailboxEventController.add(OpenMailboxViewEvent(context, presentationMailboxSelected));
  }

  void goToCreateNewMailboxView(BuildContext context, {PresentationMailbox? parentMailbox}) async {
    if (session !=null && accountId != null) {
      final arguments = MailboxCreatorArguments(
          accountId!,
          defaultMailboxTree.value,
          personalMailboxTree.value,
          teamMailboxesTree.value,
          mailboxDashBoardController.sessionCurrent!,
          parentMailbox
        );

      final result = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.mailboxCreator, arguments: arguments)
        : await push(AppRoutes.mailboxCreator, arguments: arguments);

      if (result != null && result is NewMailboxArguments) {
        _createNewMailboxAction(
          session!,
          accountId!,
          CreateNewMailboxRequest(
            result.newName,
            parentId: result.mailboxLocation?.id,
          ),
        );
      }
    }
  }

  void _createNewMailboxAction(Session session, AccountId accountId, CreateNewMailboxRequest request) async {
    consumeState(_createNewMailboxInteractor.execute(session, accountId, request));
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).createFolderSuccessfullyMessage(success.newMailbox.name?.name ?? ''),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox);

      _newFolderId = success.newMailbox.id;
    }
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).createNewFolderFailure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).createNewFolderFailure;
      }
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void _renameMailboxSuccess(RenameMailboxSuccess success) {
    updateMailboxNameById(success.request.mailboxId, success.request.newName);
  }

  void _renameMailboxFailure(RenameMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).renameFolderFailure;
      if (exception is EmptyMailboxNameException) {
        messageError = AppLocalizations.of(currentContext!).nameOfFolderIsRequired;
      } else if (exception is ContainsInvalidCharactersMailboxNameException) {
        messageError = AppLocalizations.of(currentContext!).folderNameCannotContainSpecialCharacters;
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

  void enableSelectionMailbox() {
    currentSelectMode.value = SelectMode.ACTIVE;
  }

  void disableSelectionMailbox() {
    _cancelSelectMailbox();
  }

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

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
          MailboxActions.delete
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

  void _cancelSelectMailbox() {
    unAllSelectedMailboxNode();
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  List<PresentationMailbox> get listMailboxSelected {
    final defaultMailboxSelected = defaultMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    final folderMailboxSelected = personalMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    final teamMailboxesSelected = teamMailboxesTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    return [defaultMailboxSelected, folderMailboxSelected, teamMailboxesSelected]
      .expand((node) => node)
      .map((node) => node.item)
      .toList();
  }

  void pressMailboxSelectionAction(
      BuildContext context,
      MailboxActions actions,
      List<PresentationMailbox> selectedMailboxList
  ) {
    switch(actions) {
      case MailboxActions.delete:
        _openConfirmationDialogDeleteMultipleMailboxAction(context, selectedMailboxList);
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          selectedMailboxList.first,
          responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction
        );
        break;
      case MailboxActions.markAsRead:
        markAsReadMailboxAction(
          context,
          selectedMailboxList.first,
          mailboxDashBoardController,
          onCallbackAction: closeMailboxScreen
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          selectedMailboxList.first,
          mailboxDashBoardController,
          onMovingMailboxAction: (mailboxSelected, destinationMailbox) => _invokeMovingMailboxAction(context, mailboxSelected, destinationMailbox)
        );
        break;
      default:
        break;
    }
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          [presentationMailbox],
          defaultMailboxTree.value,
          personalMailboxTree.value);
      final mapDescendantIds = tupleMap.value1;
      final listMailboxId = tupleMap.value2;

      consumeState(_deleteMultipleMailboxInteractor.execute(
        session!,
        accountId!,
        mapDescendantIds,
        listMailboxId,
      ));
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    _cancelSelectMailbox();
    popBack();
  }

  void _deleteMultipleMailboxSuccess(
      List<MailboxId> listMailboxIdDeleted,
      jmap.State? currentMailboxState
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteFoldersSuccessfully);
    }

    if (listMailboxIdDeleted.contains(selectedMailbox?.id)) {
      _switchBackToMailboxDefault();
      _closeEmailViewIfMailboxDisabledOrNotExist(listMailboxIdDeleted);
    }
  }

  void _openConfirmationDialogDeleteMultipleMailboxAction(
      BuildContext context,
      List<PresentationMailbox> selectedMailboxList
  ) {
    if (responsiveUtils.isLandscapeMobile(context) ||
        responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context)
            .messageConfirmationDialogDeleteMultipleFolder(selectedMailboxList.length))
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () =>
            _deleteMultipleMailboxAction(selectedMailboxList)))
        .show();
    } else {
      Get.dialog(
        PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_delete_multiple_mailbox'))
          ..title(AppLocalizations.of(context).deleteFolders)
          ..content(AppLocalizations.of(context).messageConfirmationDialogDeleteMultipleFolder(selectedMailboxList.length))
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog))
          ..onCloseButtonAction(() => popBack())
          ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
              _deleteMultipleMailboxAction(selectedMailboxList))
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
              popBack()))
          .build()
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _deleteMultipleMailboxAction(List<PresentationMailbox> selectedMailboxList) {
    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree.value,
          personalMailboxTree.value);
      final mapDescendantIds = tupleMap.value1;
      final listMailboxId = tupleMap.value2;
      consumeState(_deleteMultipleMailboxInteractor.execute(
        session!,
        accountId!,
        mapDescendantIds,
        listMailboxId,
      ));
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    _cancelSelectMailbox();
    popBack();
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
        leadingSVGIcon: imagePaths.icDeleteToast
      );
    }
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, MailboxName newMailboxName) {
    if (session != null && accountId != null) {
      consumeState(_renameMailboxInteractor.execute(
        session!,
        accountId!,
        RenameMailboxRequest(presentationMailbox.id, newMailboxName))
      );
    }

    _cancelSelectMailbox();
  }

  void _handleMovingMailbox(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveAction moveAction,
    PresentationMailbox mailboxSelected,
    {PresentationMailbox? destinationMailbox}
  ) {
    consumeState(_moveMailboxInteractor.execute(
      session,
      accountId,
      MoveMailboxRequest(
        mailboxSelected.id,
        moveAction,
        destinationMailboxId: destinationMailbox?.id,
        destinationMailboxDisplayName: destinationMailbox?.getDisplayName(context),
        parentId: mailboxSelected.parentId)));
  }

  void _moveMailboxSuccess(MoveMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving
        && currentOverlayContext != null
        && currentContext != null) {
      appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).movedToFolder(
              success.destinationMailboxDisplayName ?? AppLocalizations.of(currentContext!).allFolders),
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            _undoMovingMailbox(MoveMailboxRequest(
                success.mailboxIdSelected,
                MoveAction.undo,
                destinationMailboxId: success.parentId,
                parentId: success.destinationMailboxId));
          },
          leadingSVGIcon: imagePaths.icFolderMailbox,
          leadingSVGIconColor: Colors.white,
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    if (session != null && accountId != null) {
      consumeState(_moveMailboxInteractor.execute(
        session!,
        accountId!,
        newMoveRequest,
      ));
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) async {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.personalFolders:
        final newExpandMode = mailboxCategoriesExpandMode.value.personalFolders == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.personalFolders = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        if (personalMailboxTree.value.root.hasChildren()) {
          _triggerToggleMailboxCategories();
        }
        break;
      case MailboxCategories.teamMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.teamMailboxes = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        if (personalMailboxTree.value.root.hasChildren() && mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.COLLAPSE) {
          _triggerToggleMailboxCategories();
        }
        break;
      case MailboxCategories.appGrid:
        final currentExpandMode = mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value;
        if (currentExpandMode == ExpandMode.COLLAPSE) {
          _showAppDashboardAction();
        } else {
          mailboxDashBoardController.appGridDashboardController.toggleAppGridDashboard();
        }
        break;
    }
  }

  void _triggerToggleMailboxCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    mailboxListScrollController.animateTo(
      mailboxListScrollController.offset + 100,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInToLinear);
  }

  void _handleNavigationRouteParameters(Map<String, dynamic>? parameters) {
    log('MailboxController::_handleNavigationRouteParameters(): parameters: $parameters');
    if (parameters != null) {
      final navigationRouter = RouteUtils.parsingRouteParametersToNavigationRouter(parameters);
      log('MailboxController::_handleNavigationRouteParameters():navigationRouter: $navigationRouter');
      _navigationRouter = navigationRouter;
    }
  }

  void _showAppDashboardAction() {
    mailboxDashBoardController.showAppDashboardAction();
  }

  void handleMailboxAction(
      BuildContext context,
      MailboxActions actions,
      PresentationMailbox mailbox
  ) {
    popBack();

    switch(actions) {
      case MailboxActions.delete:
        openConfirmationDialogDeleteMailboxAction(
          context,
          responsiveUtils,
          imagePaths,
          mailbox,
          onDeleteMailboxAction: _deleteMailboxAction
        );
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          mailbox,
          responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onMovingMailboxAction: (mailboxSelected, destinationMailbox) => _invokeMovingMailboxAction(context, mailboxSelected, destinationMailbox)
        );
        break;
      case MailboxActions.markAsRead:
      case MailboxActions.confirmMailSpam:
        markAsReadMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onCallbackAction: closeMailboxScreen
        );
        break;
      case MailboxActions.openInNewTab:
        openMailboxInNewTabAction(mailbox);
        break;
      case MailboxActions.copySubaddress:
        try{
          final subaddress = getSubaddress(mailboxDashBoardController.userEmail, findNodePathWithSeparator(mailbox.id, '.')!);
          copySubaddressAction(context, subaddress);
        } catch (error) {
          appToast.showToastErrorMessage(context, AppLocalizations.of(context).errorWhileFetchingSubaddress);
        }
        break;
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        mailboxDashBoardController.storeSpamReportStateAction();
        break;
      case MailboxActions.disableMailbox:
        _unsubscribeMailboxAction(mailbox.id);
        break;
      case MailboxActions.allowSubaddressing:
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
      case MailboxActions.recoverDeletedMessages:
        mailboxDashBoardController.gotoEmailRecovery();
        break;
      default:
        break;
    }
  }

  void _invokeMovingMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    PresentationMailbox? destinationMailbox
  ) {
    if (session != null && accountId != null) {
      _handleMovingMailbox(
        context,
        session!,
        accountId!,
        MoveAction.moving,
        mailboxSelected,
        destinationMailbox: destinationMailbox
      );
      _cancelSelectMailbox();
    }
  }

  void _replaceBrowserHistory() {
    log('MailboxController::_replaceBrowserHistory:selectedMailbox: ${selectedMailbox?.id}');
    if (PlatformInfo.isWeb && Get.currentRoute.startsWith(AppRoutes.dashboard)) {
      final selectedMailboxId = selectedMailbox?.id;
      final route = RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          mailboxId: selectedMailboxId,
          searchQuery: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? mailboxDashBoardController.searchController.searchQuery
            : null,
          dashboardType: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? DashboardType.search
            : DashboardType.normal
        )
      );
      RouteUtils.replaceBrowserHistory(
        title: 'Mailbox-${selectedMailboxId?.id.value}',
        url: route
      );
    }
  }

  void closeMailboxScreen(BuildContext context) {
    _cancelSelectMailbox();
    mailboxDashBoardController.closeMailboxMenuDrawer();
  }

  void autoScrollTop() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear);
  }

  void autoScrollBottom() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear);
  }

  void stopAutoScroll() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn);
  }

  Future<void> _handleGetAllMailboxSuccess(GetAllMailboxSuccess success) async {
    currentMailboxState = success.currentMailboxState;
    log('MailboxController::_handleGetAllMailboxSuccess:currentMailboxState: $currentMailboxState');
    final listMailboxDisplayed = success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes;
    await buildTree(listMailboxDisplayed);
    if (currentContext != null) {
      syncAllMailboxWithDisplayName(currentContext!);
    }
    _setMapMailbox();
    _setOutboxMailbox();
  }

  Future<void> _updateMailboxIdsBlockNotificationToKeychain(List<PresentationMailbox> mailboxes) async {
    _iosSharingManager = getBinding<IOSSharingManager>();
    if (accountId == null || _iosSharingManager == null || mailboxes.isEmpty) {
      logError('MailboxController::_updateMailboxIdsBlockNotificationToKeychain: AccountId = $accountId | IosSharingManager = $_iosSharingManager | Mailboxes = ${mailboxes.length}');
      return;
    }

    if (await _iosSharingManager!.isExistMailboxIdsBlockNotificationInKeyChain(accountId!)) {
      return;
    }

    final mailboxIdsBlockNotification = mailboxes
      .where((presentationMailbox) => presentationMailbox.pushNotificationDeactivated && presentationMailbox.mailboxId != null)
      .map((presentationMailbox) => presentationMailbox.mailboxId!)
      .toList();
    log('MailboxController::_updateMailboxIdsBlockNotificationToKeychain:MailboxIdsBlockNotification = $mailboxIdsBlockNotification');
    _iosSharingManager!.updateMailboxIdsBlockNotificationInKeyChain(
      accountId: accountId!,
      mailboxIds: mailboxIdsBlockNotification);
  }

  void _unsubscribeMailboxAction(MailboxId mailboxId) {
    if (session != null && accountId != null) {
      final subscribeRequest = generateSubscribeRequest(
        mailboxId,
        MailboxSubscribeState.disabled,
        MailboxSubscribeAction.unSubscribe
      );

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(
          session!,
          accountId!,
          subscribeRequest,
        ));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(
          session!,
          accountId!,
          subscribeRequest,
        ));
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

  void _handleUnsubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess success) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }
  }

  void _handleUnsubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess success) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }
  }

  void _closeEmailViewIfMailboxDisabledOrNotExist(List<MailboxId> mailboxIdsDisabled) {
    if (selectedEmail == null) {
      return;
    }

    final mailboxContain = selectedEmail!.findMailboxContain(mailboxDashBoardController.mapMailboxById);
    if (mailboxContain != null && mailboxIdsDisabled.contains(mailboxContain.id)) {
      mailboxDashBoardController.clearSelectedEmail();
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideFolderSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _undoUnsubscribeMailboxAction(
          mailboxIdSubscribed,
          listDescendantMailboxIds: listDescendantMailboxIds
        ),
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void _undoUnsubscribeMailboxAction(
    MailboxId mailboxIdSubscribed,
    {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (session != null && accountId != null) {
      SubscribeRequest? subscribeRequest;

      if (listDescendantMailboxIds != null) {
        subscribeRequest = SubscribeMultipleMailboxRequest(
          mailboxIdSubscribed,
          listDescendantMailboxIds,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo
        );
      } else {
        subscribeRequest = SubscribeMailboxRequest(
          mailboxIdSubscribed,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo
        );
      }

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(
          session!,
          accountId!,
          subscribeRequest,
        ));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(
          session!,
          accountId!,
          subscribeRequest,
        ));
      }
    }
  }

  void _handleSubaddressingAction(MailboxId mailboxId, Map<String, List<String>?>? currentRights, MailboxActions subaddressingAction) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && accountId != null) {
      final allowSubaddressingRequest = MailboxRightRequest(
          mailboxId,
          currentRights,
          subaddressingAction == MailboxActions.allowSubaddressing ? MailboxSubaddressingAction.allow : MailboxSubaddressingAction.disallow
      );

      consumeState(_subaddressingInteractor.execute(session, accountId, allowSubaddressingRequest));
    } else {
      _handleSubaddressingFailure(SubaddressingFailure.withException(NullSessionOrAccountIdException()));
    }

    popBack();
  }

  void _handleSubaddressingFailure(SubaddressingFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final messageError = AppLocalizations.of(currentContext!).toastMessageSubaddressingFailure;
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void _handleSubaddressingSuccess(SubaddressingSuccess success) {
    appToast.showToastSuccessMessage(
      currentOverlayContext!,
      success.subaddressingAction == MailboxSubaddressingAction.allow
          ? AppLocalizations.of(currentContext!).toastMessageAllowSubaddressingSuccess
          : AppLocalizations.of(currentContext!).toastMessageDisallowSubaddressingSuccess,
    );
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
    final newMailboxNode = findMailboxNodeById(_newFolderId!);
    log('MailboxController::_redirectToNewFolder:newMailboxNode: $newMailboxNode');
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
          curve: Curves.fastOutSlowIn
        );
      }
    });
  }

  void emptyMailboxAction(BuildContext context, PresentationMailbox presentationMailbox) {
    log('MailboxController::emptyMailboxAction:presentationMailbox: ${presentationMailbox.name}');
    if (presentationMailbox.isTrash) {
      mailboxDashBoardController.emptyTrashFolderAction(
        trashFolderId: presentationMailbox.id,
        totalEmails: presentationMailbox.countTotalEmails
      );
    } else if (presentationMailbox.isSpam) {
      mailboxDashBoardController.emptySpamFolderAction(
        spamFolderId: presentationMailbox.id,
        totalEmails: presentationMailbox.countTotalEmails
      );
    }
  }

  ContactSupportCapability? get contactSupportCapability {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) return null;

    return session.getContactSupportCapability(accountId);
  }

  void copySubaddressAction(BuildContext context, String subaddress) {
    Clipboard.setData(ClipboardData(text: subaddress));
    appToast.showToastSuccessMessage(context, AppLocalizations.of(context).emailSubaddressCopiedToClipboard);
  }

  String getSubaddress(String userEmail, String folderName) {
    if (folderName.isEmpty) {
      throw EmptyFolderNameException(folderName);
    }

    final atIndex = userEmail.indexOf('@');
    if (atIndex <= 0 || atIndex == userEmail.length - 1) {
      throw InvalidMailFormatException(userEmail);
    }

    return '${userEmail.substring(0, atIndex)}+$folderName@${userEmail.substring(atIndex + 1)}';
  }
}