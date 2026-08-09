import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_key.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_name_action.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_total_emails_count_action.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_unread_count_action.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/expand_folder_trigger_scrollable_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_action_required_tab_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/handle_favorite_tab_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef RenameMailboxActionCallback = void Function(PresentationMailbox mailbox, MailboxName newMailboxName);
typedef MovingMailboxActionCallback = void Function(PresentationMailbox mailboxSelected, PresentationMailbox? destinationMailbox);
typedef OnMoveFolderContentActionCallback = void Function(
  PresentationMailbox currentMailbox,
  PresentationMailbox destinationMailbox,
  String destinationMailboxName,
);
typedef DeleteMailboxActionCallback = void Function(PresentationMailbox mailbox);
typedef AllowSubaddressingActionCallback = void Function(MailboxId, Map<String, List<String>?>?, MailboxActions);
typedef OnUpdateMailboxCollectionCallback = MailboxCollection Function(MailboxCollection);

abstract class BaseMailboxController extends BaseController
    with ExpandFolderTriggerScrollableMixin {
  final TreeBuilder _treeBuilder;
  final VerifyNameInteractor verifyNameInteractor;
  final GetAllMailboxInteractor? getAllMailboxInteractor;
  final RefreshAllMailboxInteractor? refreshAllMailboxInteractor;
  jmap.State? currentMailboxState;
  final mailboxCategoriesExpandMode = MailboxCategoriesExpandMode.initial().obs;

  BaseMailboxController(
    this._treeBuilder,
    this.verifyNameInteractor,
    {
      this.getAllMailboxInteractor,
      this.refreshAllMailboxInteractor
    }
  );

  final personalMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final defaultMailboxTree = MailboxTree(MailboxNode.root()).obs;
  final teamMailboxesTree =  MailboxTree(MailboxNode.root()).obs;

  /// Every tree this controller owns.
  ///
  /// Operations that are not specific to one section iterate this instead of
  /// naming each tree.
  List<Rx<MailboxTree>> get allMailboxTrees => [
    defaultMailboxTree,
    personalMailboxTree,
    teamMailboxesTree,
  ];

  /// The account this controller is signed in as.
  ///
  /// Used to resolve a bare [MailboxId] that arrives without account context,
  /// such as an id carried by a state-change event on the primary account's
  /// push channel.
  AccountId? get primaryAccountId;

  /// Resolves a bare [MailboxId] known to belong to the primary account.
  ///
  /// Returns null when there is no id or no signed-in account, so callers can
  /// bail out with a single check.
  MailboxKey? primaryMailboxKey(MailboxId? mailboxId) {
    final accountId = primaryAccountId;
    if (mailboxId == null || accountId == null) return null;
    return MailboxKey(accountId, mailboxId);
  }

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];

  MailboxCollection get currentMailboxCollection => MailboxCollection(
    allMailboxes: allMailboxes,
    defaultTree: defaultMailboxTree.value,
    personalTree: personalMailboxTree.value,
    teamMailboxTree: teamMailboxesTree.value,
  );

  Future<void> buildTree(
    List<PresentationMailbox> allMailbox, {
    MailboxId? mailboxIdSelected,
    OnUpdateMailboxCollectionCallback? onUpdateMailboxCollectionCallback,
  }) async {
    MailboxCollection mailboxCollection =
        await _treeBuilder.generateMailboxTreeInUI(
      allMailboxes: allMailbox,
      currentCollection: currentMailboxCollection,
      mailboxIdSelected: mailboxIdSelected,
      primaryAccountId: primaryAccountId,
    );

    if (onUpdateMailboxCollectionCallback != null) {
      mailboxCollection = onUpdateMailboxCollectionCallback(mailboxCollection);
    }

    updateMailboxTree(mailboxCollection: mailboxCollection);
  }

  Future<void> refreshTree(
    List<PresentationMailbox> allMailbox, {
    OnUpdateMailboxCollectionCallback? onUpdateMailboxCollectionCallback,
  }) async {
    MailboxCollection mailboxCollection =
        await _treeBuilder.generateMailboxTreeInUIAfterRefreshChanges(
      allMailboxes: allMailbox,
      currentCollection: currentMailboxCollection,
      primaryAccountId: primaryAccountId,
    );

    if (onUpdateMailboxCollectionCallback != null) {
      mailboxCollection = onUpdateMailboxCollectionCallback(mailboxCollection);
    }

    updateMailboxTree(mailboxCollection: mailboxCollection);
  }

  void updateMailboxTree({
    required MailboxCollection mailboxCollection,
    bool isRefreshTrigger = true,
  }) {
    if (isRefreshTrigger) {
      defaultMailboxTree.firstRebuild = true;
      personalMailboxTree.firstRebuild = true;
      teamMailboxesTree.firstRebuild = true;
    }
    defaultMailboxTree.value = mailboxCollection.defaultTree;
    personalMailboxTree.value = mailboxCollection.personalTree;
    teamMailboxesTree.value = mailboxCollection.teamMailboxTree;
    allMailboxes = mailboxCollection.allMailboxes;
  }

  void syncAllMailboxWithDisplayName(BuildContext context) {
    final syncedMailbox = allMailboxes
      .map((mailbox) => mailbox.withDisplayName(mailbox.getDisplayName(context)))
      .toList();
    allMailboxes = syncedMailbox;
  }

  void toggleMailboxFolder(
    MailboxNode selectedMailboxNode,
    ScrollController scrollController,
    GlobalKey itemKey,
  ) {
    final newExpandMode = selectedMailboxNode.expandMode.toggle();

    for (final mailboxTree in allMailboxTrees) {
      if (mailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) == null) {
        continue;
      }
      mailboxTree.refresh();
      triggerScrollWhenExpandFolder(
        selectedMailboxNode.expandMode,
        itemKey,
        scrollController,
      );
    }
  }

  void selectMailboxNode(MailboxNode mailboxNodeSelected) {
    final newSelectMode = mailboxNodeSelected.selectMode == SelectMode.INACTIVE
        ? SelectMode.ACTIVE
        : SelectMode.INACTIVE;

    for (final mailboxTree in allMailboxTrees) {
      if (mailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
        mailboxTree.refresh();
      }
    }
  }

  void unAllSelectedMailboxNode() {
    for (final mailboxTree in allMailboxTrees) {
      mailboxTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
      mailboxTree.refresh();
    }
  }

  MailboxNode? findMailboxNodeByKey(MailboxKey mailboxKey) {
    for (final mailboxTree in allMailboxTrees) {
      final mailboxNode = mailboxTree.value.findNodeByKey(mailboxKey);
      if (mailboxNode != null) return mailboxNode;
    }
    return null;
  }

  String? findNodePathWithSeparator(MailboxKey mailboxKey, String pathSeparator) {
    for (final mailboxTree in allMailboxTrees) {
      final mailboxNodePath = mailboxTree.value.getNodePath(mailboxKey, pathSeparator);
      if (mailboxNodePath != null) {
        log('BaseMailboxController::findNodePath():mailboxNodePath: $mailboxNodePath');
        return mailboxNodePath;
      }
    }
    return null;
  }

  String? findNodePath(MailboxKey mailboxKey) {
    return findNodePathWithSeparator(mailboxKey, '/');
  }

  MailboxNode? findMailboxNodeByRole(Role role) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.role == role);
    return mailboxNode;
  }

  List<PresentationMailbox> findMailboxPath(List<PresentationMailbox> mailboxes) {
    return mailboxes.map((presentationMailbox) {
      if (!presentationMailbox.hasParentId()) {
        return presentationMailbox;
      } else {
        final mailboxNodePath = findNodePath(presentationMailbox.key);
        if (mailboxNodePath != null) {
          return presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxNodePath);
        } else {
          return presentationMailbox;
        }
      }
    }).toList();
  }

  bool get defaultMailboxIsNotEmpty =>
    defaultMailboxTree.value.root.childrenItems?.isNotEmpty ?? false;

  bool get personalMailboxIsNotEmpty =>
    personalMailboxTree.value.root.childrenItems?.isNotEmpty ?? false;
  
  bool get teamMailboxesIsNotEmpty =>
    teamMailboxesTree.value.root.childrenItems?.isNotEmpty ?? false;

  MailboxNode get defaultRootNode => defaultMailboxTree.value.root;

  MailboxNode get personalRootNode => personalMailboxTree.value.root;

  MailboxNode get teamMailboxesRootNode => teamMailboxesTree.value.root;

  List<String> getListMailboxNameInParentMailbox(PresentationMailbox parentMailbox) {
    if (parentMailbox.parentId == null) {
      // Scoped to the target account: a folder named "Projects" in the primary
      // account must not block creating "Projects" in another user's account.
      final accountId = parentMailbox.key.accountId;
      final allChildrenAtMailboxLocation = allMailboxTrees
        .expand((tree) => tree.value.root.childrenItems ?? <MailboxNode>[])
        .where((mailboxNode) => mailboxNode.item.key.accountId == accountId)
        .toList();
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        final listMailboxNameAsStringExist = allChildrenAtMailboxLocation
          .where((mailboxNode) => mailboxNode.nameNotEmpty)
          .map((mailboxNode) => mailboxNode.mailboxNameAsString)
          .toList();
        return listMailboxNameAsStringExist;
      } else {
        return [];
      }
    } else {
      final mailboxNodeLocation = findMailboxNodeByKey(
        MailboxKey(parentMailbox.key.accountId, parentMailbox.parentId!),
      );
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        final listMailboxNameAsStringExist = allChildrenAtMailboxLocation
          .where((mailboxNode) => mailboxNode.nameNotEmpty)
          .map((mailboxNode) => mailboxNode.mailboxNameAsString)
          .toList();
        return listMailboxNameAsStringExist;
      } else {
        return [];
      }
    }
  }

  String? verifyMailboxNameAction(
    BuildContext context,
    String newName,
    List<String> listMailboxName,
    MailboxActions mailboxActions
  ) {
    return verifyNameInteractor.execute(newName, [
      EmptyNameValidator(),
      NameWithSpaceOnlyValidator(),
      DuplicateNameValidator(listMailboxName),
      SpecialCharacterValidator()
    ]).fold((failure) {
      if (failure is VerifyNameFailure) {
        return failure.getMessage(context, actions: mailboxActions);
      } else {
        return null;
      }
    }, (success) => null);
  }

  void openDialogRenameMailboxAction(
    BuildContext context,
    PresentationMailbox presentationMailbox,
    ResponsiveUtils responsiveUtils, {
    required RenameMailboxActionCallback onRenameMailboxAction
  }) {
    final listMailboxName = getListMailboxNameInParentMailbox(presentationMailbox);

    if (responsiveUtils.isMobile(context)) {
      (EditTextModalSheetBuilder()
        ..key(const Key('rename_mailbox_dialog'))
        ..title(AppLocalizations.of(context).renameFolder)
        ..cancelText(AppLocalizations.of(context).cancel)
        ..boxConstraints(responsiveUtils.isLandscapeMobile(context)
            ? const BoxConstraints(maxWidth: 400)
            : null)
        ..onConfirmAction(
          AppLocalizations.of(context).rename,
          (value) => onRenameMailboxAction(presentationMailbox, MailboxName(value))
        )
        ..setErrorString((value) {
          return verifyMailboxNameAction(
              context,
              value,
              listMailboxName,
              MailboxActions.rename
          );
        })
        ..setTextController(TextEditingController.fromValue(
            TextEditingValue(
              text: presentationMailbox.name?.name ?? '',
              selection: TextSelection(
                baseOffset: 0,
                extentOffset: presentationMailbox.name?.name.length ?? 0
              )
            )))
      ).show(context);
    } else {
      MessageDialogActionManager().showInputDialogAction(
        key: const Key('rename_mailbox_dialog'),
        context: context,
        outsideDismissible: true,
        title: AppLocalizations.of(context).renameFolder,
        value: presentationMailbox.name?.name ?? '',
        negativeText: AppLocalizations.of(context).cancel,
        positiveText: AppLocalizations.of(context).rename,
        closeIcon: imagePaths.icComposerClose,
        onPositiveButtonAction: (value) {
          onRenameMailboxAction(presentationMailbox, MailboxName(value));
          popBack();
        },
        onNegativeButtonAction: popBack,
        onInputErrorChanged: (value) {
          return verifyMailboxNameAction(
            context,
            value,
            listMailboxName,
            MailboxActions.rename,
          );
        },
      );
    }
  }

  void moveMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    MailboxDashBoardController dashBoardController, {
    required MovingMailboxActionCallback onMovingMailboxAction
  }) async {
    // The picker shows destinations in the moved mailbox's own account, since a
    // move never crosses accounts.
    final accountId =
        mailboxSelected.accountId ?? dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;
    if (accountId != null && session != null) {

      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.move,
        session,
        mailboxIdSelected: mailboxSelected.id
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox is PresentationMailbox) {
        onMovingMailboxAction(
          mailboxSelected,
          destinationMailbox == PresentationMailbox.unifiedMailbox
            ? null
            : destinationMailbox
        );
      }
    }
  }

  void openConfirmationDialogDeleteMailboxAction(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    PresentationMailbox presentationMailbox, {
    required DeleteMailboxActionCallback onDeleteMailboxAction
  }) {
    if (responsiveUtils.isLandscapeMobile(context) || responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).message_confirmation_dialog_delete_folder(presentationMailbox.getDisplayName(context)))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () => onDeleteMailboxAction(presentationMailbox))
      ).show();
    } else {
      MessageDialogActionManager().showConfirmDialogAction(
        context,
        AppLocalizations.of(context).message_confirmation_dialog_delete_folder(presentationMailbox.getDisplayName(context)),
        AppLocalizations.of(context).delete,
        key: const Key('confirm_dialog_delete_mailbox'),
        title: AppLocalizations.of(context).deleteFolders,
        cancelTitle: AppLocalizations.of(context).cancel,
        onConfirmAction: () => onDeleteMailboxAction(presentationMailbox),
        onCloseButtonAction: popBack,
      );
    }
  }

  List<MailboxNode> getAncestorOfMailboxNode(MailboxNode mailboxNode) {
    for (final mailboxTree in allMailboxTrees) {
      final listAncestor = mailboxTree.value.getAncestorList(mailboxNode);
      if (listAncestor != null) return listAncestor;
    }
    return [];
  }

  SubscribeRequest? generateSubscribeRequest(
    MailboxKey mailboxKey,
    MailboxSubscribeState subscribeState,
    MailboxSubscribeAction subscribeAction
  ) {
    switch(subscribeState) {
      case MailboxSubscribeState.enabled:
        return _generateSubscribeRequestWhenSubscribeEnabled(mailboxKey, subscribeAction);
      case MailboxSubscribeState.disabled:
        return _generateSubscribeRequestWhenSubscribeDisabled(mailboxKey, subscribeAction);
    }
  }

  SubscribeRequest? _generateSubscribeRequestWhenSubscribeDisabled(
    MailboxKey mailboxKey,
    MailboxSubscribeAction subscribeAction
  ) {
    final mailboxId = mailboxKey.mailboxId;
    final mailboxNode = findMailboxNodeByKey(mailboxKey);

    if (mailboxNode == null) return null;

    if (mailboxNode.hasChildren()) {
      final listDescendantMailboxIds = mailboxNode.descendantsAsList().mailboxIds;
      log("BaseMailboxController::_generateSubscribeRequestWhenSubscribeDisabled:listDescendantMailboxIds $listDescendantMailboxIds");
      return SubscribeMultipleMailboxRequest(
        mailboxId,
        listDescendantMailboxIds,
        MailboxSubscribeState.disabled,
        subscribeAction
      );
    } else {
      return SubscribeMailboxRequest(
        mailboxId,
        MailboxSubscribeState.disabled,
        subscribeAction
      );
    }
  }

  SubscribeRequest? _generateSubscribeRequestWhenSubscribeEnabled(
    MailboxKey mailboxKey,
    MailboxSubscribeAction subscribeAction
  ) {
    final mailboxId = mailboxKey.mailboxId;
    final mailboxNode = findMailboxNodeByKey(mailboxKey);

    if (mailboxNode == null) return null;

    if (mailboxNode.hasParents()) {
      final listAncestorMailboxIds = getAncestorOfMailboxNode(mailboxNode).mailboxIds;
      listAncestorMailboxIds.add(mailboxId);
      log("BaseMailboxController::_generateSubscribeRequestWhenSubscribeEnabled:listAncestorMailboxIds $listAncestorMailboxIds");
      if (listAncestorMailboxIds.isNotEmpty) {
        return SubscribeMultipleMailboxRequest(
          mailboxId,
          listAncestorMailboxIds,
          MailboxSubscribeState.enabled,
          subscribeAction
        );
      } else {
        return SubscribeMailboxRequest(
          mailboxId,
          MailboxSubscribeState.enabled,
          subscribeAction
        );
      }
    } else {
      return SubscribeMailboxRequest(
        mailboxId,
        MailboxSubscribeState.enabled,
        subscribeAction
      );
    }
  }

  void getAllMailbox(Session session, AccountId accountId) async {
    if (getAllMailboxInteractor != null) {
      consumeState(getAllMailboxInteractor!.execute(session, accountId));
    }
  }

  void refreshMailboxChanges(
    Session session,
    AccountId accountId,
    jmap.State currentMailboxState,
    {Properties? properties}
  ) {
    if (refreshAllMailboxInteractor != null) {
      log('BaseMailboxController::refreshMailboxChanges(): currentMailboxState: $currentMailboxState');
      consumeState(refreshAllMailboxInteractor!.execute(
        session,
        accountId,
        currentMailboxState,
        properties: properties
      ));
    }
  }

  MailboxNode? findNodeByNameOnFirstLevel(String name) {
    MailboxNode? mailboxNode = defaultMailboxTree.value.findNodeOnFirstLevel((node) => node.item.name?.name.toLowerCase() == name);
    if (mailboxNode != null) {
      return mailboxNode;
    }
    mailboxNode = personalMailboxTree.value.findNodeOnFirstLevel((node) => node.item.name?.name.toLowerCase() == name);
    return mailboxNode;
  }

  void updateMailboxNameByKey(MailboxKey mailboxKey, MailboxName mailboxName) {
    UpdateMailboxNameAction(
      mailboxTrees: allMailboxTrees,
      mailboxKey: mailboxKey,
      mailboxName: mailboxName,
    ).execute();
  }

  void updateUnreadCountOfMailboxByKey(
    MailboxKey mailboxKey, {
    required int unreadChanges,
  }) {
    UpdateMailboxUnreadCountAction(
      mailboxTrees: allMailboxTrees,
      mailboxKey: mailboxKey,
      unreadChanges: unreadChanges,
    ).execute();
  }

  void clearUnreadCount(MailboxKey mailboxKey) {
    // No early exit once a tree matches: the same mailbox can be present in
    // more than one tree, and stopping at the first would leave the others
    // showing a stale count.
    for (var mailboxTree in allMailboxTrees) {
      final selectedNode = mailboxTree.value.findNodeByKey(mailboxKey);
      if (selectedNode == null) continue;
      final currentUnreadCount = selectedNode.item.unreadEmails?.value.value.toInt();
      mailboxTree.value.updateMailboxUnreadCountByKey(
        mailboxKey,
        -(currentUnreadCount ?? 0));
      mailboxTree.refresh();
    }
  }

  void updateMailboxTotalEmailsCountByKey(MailboxKey mailboxKey, int totalEmails) {
    UpdateMailboxTotalEmailsCountAction(
      mailboxTrees: allMailboxTrees,
      mailboxKey: mailboxKey,
      totalEmailsCountChanged: totalEmails,
    ).execute();
  }

  void toggleMailboxCategories(
    MailboxCategories category,
    ScrollController scrollController,
    GlobalKey itemKey,
  ) {
    switch (category) {
      case MailboxCategories.exchange:
        _toggleAndScroll(
          currentExpandMode: mailboxCategoriesExpandMode.value.defaultMailbox,
          updateExpandMode: (mode) => mailboxCategoriesExpandMode.value.defaultMailbox = mode,
          hasChildren: defaultMailboxTree.value.root.hasChildren(),
          itemKey: itemKey,
          scrollController: scrollController,
        );
        break;

      case MailboxCategories.personalFolders:
        _toggleAndScroll(
          currentExpandMode: mailboxCategoriesExpandMode.value.personalFolders,
          updateExpandMode: (mode) => mailboxCategoriesExpandMode.value.personalFolders = mode,
          hasChildren: personalMailboxTree.value.root.hasChildren(),
          itemKey: itemKey,
          scrollController: scrollController,
        );
        break;

      case MailboxCategories.teamMailboxes:
        _toggleAndScroll(
          currentExpandMode: mailboxCategoriesExpandMode.value.teamMailboxes,
          updateExpandMode: (mode) => mailboxCategoriesExpandMode.value.teamMailboxes = mode,
          hasChildren: teamMailboxesTree.value.root.hasChildren(),
          itemKey: itemKey,
          scrollController: scrollController,
        );
        break;
    }
  }

  void _toggleAndScroll({
    required ExpandMode currentExpandMode,
    required void Function(ExpandMode) updateExpandMode,
    required bool hasChildren,
    required GlobalKey itemKey,
    required ScrollController scrollController,
  }) {
    final newExpandMode = currentExpandMode.toggle();
    updateExpandMode(newExpandMode);
    mailboxCategoriesExpandMode.refresh();

    if (hasChildren) {
      triggerScrollWhenExpandFolder(newExpandMode, itemKey, scrollController);
    }
  }

  void moveFolderContentAction({
    required AppLocalizations appLocalizations,
    required AccountId accountId,
    required Session session,
    required PresentationMailbox mailboxSelected,
    required OnMoveFolderContentActionCallback onMoveFolderContentAction,
  }) async {
    // The picker shows destinations in the source folder's own account.
    final destinationAccountId = mailboxSelected.accountId ?? accountId;
    final arguments = DestinationPickerArguments(
      destinationAccountId,
      MailboxActions.moveFolderContent,
      session,
      mailboxIdSelected: mailboxSelected.id,
    );

    final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter().pushGeneralDialog(
            routeName: AppRoutes.destinationPicker,
            arguments: arguments,
          )
        : await push(AppRoutes.destinationPicker, arguments: arguments);
    if (destinationMailbox is PresentationMailbox) {
      log('$runtimeType::moveFolderContentAction: DestinationMailbox is ${destinationMailbox.name?.name}');
      onMoveFolderContentAction(
        mailboxSelected,
        destinationMailbox,
        destinationMailbox.getDisplayNameWithoutContext(appLocalizations),
      );
    }
  }

  bool get isAINeedsActionEnabled => false;

  MailboxCollection updateMailboxCollection(MailboxCollection mailboxCollection) {
    MailboxCollection updated = addFavoriteFolderToMailboxList(
      mailboxCollection: mailboxCollection,
    );
    if (isAINeedsActionEnabled) {
      updated = addActionRequiredFolder(mailboxCollection: updated);
    }
    return updated;
  }
}