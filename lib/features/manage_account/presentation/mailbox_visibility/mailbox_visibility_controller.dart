import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/mailbox/mailbox_key.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_account_resolver_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/other_user_account_mailboxes.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/state/mailbox_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxVisibilityController extends BaseMailboxController
    with MailboxAccountResolverMixin {
  SubscribeMailboxInteractor? _subscribeMailboxInteractor;
  SubscribeMultipleMailboxInteractor? _subscribeMultipleMailboxInteractor;
  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final mailboxListScrollController = ScrollController();
  final foldersExpandMode = Rx(ExpandMode.EXPAND);

  /// Last known primary-account mailboxes, so a delegated-account load or a
  /// primary refresh can rebuild without dropping the other section.
  List<PresentationMailbox> _primaryMailboxes = const [];

  /// Loaded mailboxes for each delegated account shown in this screen.
  final Map<AccountId, OtherUserAccountMailboxes> _otherUserAccounts = {};

  @override
  AccountId? get primaryAccountId => _accountDashBoardController.accountId.value;

  @override
  Session? get session => _accountDashBoardController.sessionCurrent;

  MailboxVisibilityController(
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor refreshAllMailboxInteractor
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    super.onInit();
    try {
      _subscribeMailboxInteractor = Get.find<SubscribeMailboxInteractor>();
      _subscribeMultipleMailboxInteractor = Get.find<SubscribeMultipleMailboxInteractor>();
    } catch (e) {
      logWarning('MailboxVisibilityController::onInit(): ${e.toString()}');
    }
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess)  {
      currentMailboxState = success.currentMailboxState;
      _primaryMailboxes = success.mailboxList;
      _handleBuildTree();
    } else if (success is RefreshChangesAllMailboxSuccess) {
      currentMailboxState = success.currentMailboxState;
      _primaryMailboxes = success.mailboxList;
      await _rebuildVisibilityTrees(refreshOnly: true);
      if (currentContext != null) {
        syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is SubscribeMailboxSuccess) {
      _subscribeMailboxSuccess(success);
    } else if (success is SubscribeMultipleMailboxAllSuccess) {
      _handleUnsubscribeMultipleMailboxAllSuccess(success);
    } else if (success is SubscribeMultipleMailboxHasSomeSuccess) {
      _handleUnsubscribeMultipleMailboxHasSomeSuccess(success);
    }
  }

  @override
  void onReady() {
    final session = _accountDashBoardController.sessionCurrent;
    final accountId = _accountDashBoardController.accountId.value;
    if(session != null && accountId != null) {
      getAllMailbox(session, accountId);
      _loadOtherUserMailboxes(session, accountId);
    }
    super.onReady();
  }

  void _handleBuildTree() async {
    dispatchState(Right(LoadingBuildTreeMailboxVisibility()));
    await _rebuildVisibilityTrees();
    dispatchState(Right(BuildTreeMailboxVisibilitySuccess()));
    if (currentContext != null) {
      syncAllMailboxWithDisplayName(currentContext!);
    }
  }

  Future<void> _rebuildVisibilityTrees({bool refreshOnly = false}) async {
    final sharedMailboxes = _otherUserAccounts.values
        .expand((account) => account.mailboxes)
        .toList();
    final composed = [..._primaryMailboxes, ...sharedMailboxes];

    if (refreshOnly) {
      await refreshTree(composed);
    } else {
      await buildTree(composed);
    }
  }

  /// Loads the delegated accounts so their folders can be shown and toggled
  /// here. Unlike the sidebar this keeps the full folder list (not just
  /// readable ones), because the point of the screen is to manage visibility.
  Future<void> _loadOtherUserMailboxes(Session session, AccountId primary) async {
    final accountIds =
        MailboxUtils.resolveOtherUserAccountIds(session, primary);

    await Future.wait(accountIds.map((accountId) async {
      // Run the interactor directly, never via consumeState, so its
      // GetAllMailboxSuccess is not routed into the primary tree build.
      await for (final result
          in getAllMailboxInteractor!.execute(session, accountId)) {
        final success = result.fold<GetAllMailboxSuccess?>(
          (_) => null,
          (s) => s is GetAllMailboxSuccess ? s : null,
        );
        if (success == null) continue;

        // Ghost account: listed in the session but with no readable mailbox.
        // Skip it so it does not appear in the visibility settings either.
        final readableMailboxes = success.mailboxList.listReadableMailboxes;
        if (readableMailboxes.isEmpty) continue;

        final ownerName =
            session.accounts[accountId]?.name.value ?? accountId.id.value;
        final mailboxes = readableMailboxes
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
        await _rebuildVisibilityTrees();
      }
    }));
  }

  void subscribeMailbox(MailboxNode mailboxNode) {
    final mailboxSubscribeState = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeState.disabled : MailboxSubscribeState.enabled;
    final mailboxSubscribeStateAction = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeAction.unSubscribe : MailboxSubscribeAction.subscribe;
    // Subscribe runs against the account that owns the mailbox, resolved from
    // its account-scoped key.
    // Note: RFC 8621 says isSubscribed defaults to false in shared accounts, so
    // the subscription model for delegated mailboxes is imperfect; a follow-up
    // will address it. Here we simply route the toggle to the right account.
    _subscribeMailboxAction(
        SubscribeMailboxRequest(
          mailboxNode.item.id,
          mailboxSubscribeState,
          mailboxSubscribeStateAction,
        ),
        mailboxNode.item.key.accountId,
    );
  }

  void _subscribeMailboxAction(
    SubscribeMailboxRequest subscribeMailboxRequest,
    AccountId owningAccountId,
  ) {
    final session = _accountDashBoardController.sessionCurrent;
    if (session != null) {
      final subscribeRequest = generateSubscribeRequest(
        MailboxKey(owningAccountId, subscribeMailboxRequest.mailboxId),
        subscribeMailboxRequest.subscribeState,
        subscribeMailboxRequest.subscribeAction
      );

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor!.execute(session, owningAccountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor!.execute(session, owningAccountId, subscribeRequest));
      }
    }
  }

  void _subscribeMailboxSuccess(SubscribeMailboxSuccess subscribeMailboxSuccess) {
    if (subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe
        && currentOverlayContext != null
        && currentContext != null) {
        _showToastSubscribeMailboxSuccess(subscribeMailboxSuccess.mailboxId);
    }

    _reflectSubscribeChange(
      anchorMailboxId: subscribeMailboxSuccess.mailboxId,
      affectedMailboxIds: {subscribeMailboxSuccess.mailboxId},
      subscribeAction: subscribeMailboxSuccess.subscribeAction,
    );
  }

  void _handleUnsubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess subscribeMailboxSuccess) {
    if(subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        subscribeMailboxSuccess.parentMailboxId,
        listDescendantMailboxIds: subscribeMailboxSuccess.mailboxIdsSubscribe
      );
    }

    _reflectSubscribeChange(
      anchorMailboxId: subscribeMailboxSuccess.parentMailboxId,
      affectedMailboxIds: {
        subscribeMailboxSuccess.parentMailboxId,
        ...subscribeMailboxSuccess.mailboxIdsSubscribe,
      },
      subscribeAction: subscribeMailboxSuccess.subscribeAction,
    );
  }

  void _handleUnsubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess subscribeMailboxSuccess) {
    if(subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
          subscribeMailboxSuccess.parentMailboxId,
          listDescendantMailboxIds: subscribeMailboxSuccess.mailboxIdsSubscribe
      );
    }

    _reflectSubscribeChange(
      anchorMailboxId: subscribeMailboxSuccess.parentMailboxId,
      affectedMailboxIds: {
        subscribeMailboxSuccess.parentMailboxId,
        ...subscribeMailboxSuccess.mailboxIdsSubscribe,
      },
      subscribeAction: subscribeMailboxSuccess.subscribeAction,
    );
  }

  /// Applies a subscribe/unsubscribe result optimistically to the owning
  /// account, then rebuilds.
  ///
  /// The Mailbox/set already persisted the change, and a subscription toggle
  /// does not advance the mailbox modseq that Mailbox/changes is based on, so a
  /// server refresh cannot observe it. Flipping isSubscribed in the cached list
  /// keeps Personal Folders and Other Users behaving identically on show/hide.
  void _reflectSubscribeChange({
    required MailboxId anchorMailboxId,
    required Set<MailboxId> affectedMailboxIds,
    required MailboxSubscribeAction subscribeAction,
  }) async {
    final owningAccountId = _accountIdOfMailboxId(anchorMailboxId);
    final subscribed = subscribeAction == MailboxSubscribeAction.subscribe;

    final delegated = _otherUserAccounts[owningAccountId];
    if (delegated != null) {
      _otherUserAccounts[owningAccountId] = delegated.copyWith(
        mailboxes:
            _flipSubscribed(delegated.mailboxes, affectedMailboxIds, subscribed),
      );
    } else {
      _primaryMailboxes =
          _flipSubscribed(_primaryMailboxes, affectedMailboxIds, subscribed);
    }
    await _rebuildVisibilityTrees();
  }

  List<PresentationMailbox> _flipSubscribed(
    List<PresentationMailbox> mailboxes,
    Set<MailboxId> mailboxIds,
    bool subscribed,
  ) =>
      mailboxes
          .map((mailbox) => mailboxIds.contains(mailbox.id)
              ? mailbox.copyWith(isSubscribed: IsSubscribed(subscribed))
              : mailbox)
          .toList();

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideFolderSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _subscribeMailboxAction(
          SubscribeMailboxRequest(
            mailboxIdSubscribed,
            MailboxSubscribeState.enabled,
            MailboxSubscribeAction.subscribe
          ),
          _accountIdOfMailboxId(mailboxIdSubscribed),
        ),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  /// Resolves the owning account of a mailbox placed in a tree, by id, falling
  /// back to the primary account.
  AccountId _accountIdOfMailboxId(MailboxId mailboxId) {
    for (final mailboxTree in allMailboxTrees) {
      final node =
          mailboxTree.value.findNode((node) => node.item.id == mailboxId);
      final accountId = node?.item.accountId;
      if (accountId != null) return accountId;
    }
    return _accountDashBoardController.accountId.value!;
  }

  @override
  void onClose() {
    mailboxListScrollController.dispose();
    super.onClose();
  }
}
