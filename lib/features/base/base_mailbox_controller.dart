import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
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
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_name_action.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_total_emails_count_action.dart';
import 'package:tmail_ui_user/features/base/action/update_mailbox_properties_action/update_mailbox_unread_count_action.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
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
typedef DeleteMailboxActionCallback = void Function(PresentationMailbox mailbox);
typedef AllowSubaddressingActionCallback = void Function(MailboxId, Map<String, List<String>?>?, MailboxActions);

abstract class BaseMailboxController extends BaseController {
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

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];

  Future<void> buildTree(
      List<PresentationMailbox> allMailbox,
      {MailboxId? mailboxIdSelected}
  ) async {
    final recordTree = await _treeBuilder.generateMailboxTreeInUI(
      allMailboxes: allMailbox,
      currentDefaultTree: defaultMailboxTree.value,
      currentPersonalTree: personalMailboxTree.value,
      currentTeamMailboxTree: teamMailboxesTree.value,
      mailboxIdSelected: mailboxIdSelected,
    );
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = recordTree.defaultTree;
    personalMailboxTree.value = recordTree.personalTree;
    teamMailboxesTree.value = recordTree.teamMailboxTree;
    allMailboxes = recordTree.allMailboxes;
  }

  Future<void> refreshTree(List<PresentationMailbox> allMailbox) async {
    final recordTree = await _treeBuilder.generateMailboxTreeInUIAfterRefreshChanges(
      allMailboxes: allMailbox,
      currentDefaultTree: defaultMailboxTree.value,
      currentPersonalTree: personalMailboxTree.value,
      currentTeamMailboxTree: teamMailboxesTree.value,
    );
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = recordTree.defaultTree;
    personalMailboxTree.value = recordTree.personalTree;
    teamMailboxesTree.value = recordTree.teamMailboxTree;
    allMailboxes = allMailbox;
  }

  void syncAllMailboxWithDisplayName(BuildContext context) {
    final syncedMailbox = allMailboxes
      .map((mailbox) => mailbox.withDisplayName(mailbox.getDisplayName(context)))
      .toList();
    allMailboxes = syncedMailbox;
  }

  void toggleMailboxFolder(MailboxNode selectedMailboxNode, ScrollController scrollController) {
    final newExpandMode = selectedMailboxNode.expandMode == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;

    if (defaultMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (personalMailboxTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh folderMailboxTree');
      personalMailboxTree.refresh();
      final childrenItems = personalMailboxTree.value.root.childrenItems ?? [];
      _triggerScrollWhenExpandMailboxFolder(
        childrenItems,
        selectedMailboxNode,
        scrollController);
    }

    if (teamMailboxesTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh teamMailboxesTree');
      teamMailboxesTree.refresh();
      final childrenItems = teamMailboxesTree.value.root.childrenItems ?? [];
      _triggerScrollWhenExpandMailboxFolder(
          childrenItems,
          selectedMailboxNode,
          scrollController);
    }
  }

  void _triggerScrollWhenExpandMailboxFolder(
      List<MailboxNode> childrenItems,
      MailboxNode selectedMailboxNode,
      ScrollController scrollController) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lastItem = childrenItems.last;

    if (selectedMailboxNode.expandMode == ExpandMode.COLLAPSE) {
      return;
    }

    if (lastItem.mailboxNameAsString.contains(selectedMailboxNode.mailboxNameAsString)) {
      scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInToLinear);
    } else {
      scrollController.animateTo(
          scrollController.offset + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInToLinear);
    }
  }

  void selectMailboxNode(MailboxNode mailboxNodeSelected) {
    final newSelectMode = mailboxNodeSelected.selectMode == SelectMode.INACTIVE
        ? SelectMode.ACTIVE
        : SelectMode.INACTIVE;

    if (defaultMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh defaultMailboxTree');
      defaultMailboxTree.refresh();
    }

    if (personalMailboxTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh folderMailboxTree');
      personalMailboxTree.refresh();
    }

    if (teamMailboxesTree.value.updateSelectedNode(mailboxNodeSelected, newSelectMode) != null) {
      log('selectMailboxNode() refresh folderMailboxTree');
      teamMailboxesTree.refresh();
    }
  }

  void unAllSelectedMailboxNode() {
    defaultMailboxTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    personalMailboxTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    teamMailboxesTree.value.updateNodesUIMode(selectMode: SelectMode.INACTIVE);
    defaultMailboxTree.refresh();
    personalMailboxTree.refresh();
    teamMailboxesTree.refresh();
  }

  MailboxNode? findMailboxNodeById(MailboxId mailboxId) {
    final mailboxNode = defaultMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    if (mailboxNode != null) {
      return mailboxNode;
    }

    final mailboxPersonal = personalMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    if (mailboxPersonal != null) {
      return mailboxPersonal;
    }
    return teamMailboxesTree.value.findNode((node) => node.item.id == mailboxId);
  }

  String? findNodePathWithSeparator(MailboxId mailboxId, String pathSeparator) {
    var mailboxNodePath = defaultMailboxTree.value.getNodePath(mailboxId, pathSeparator)
      ?? personalMailboxTree.value.getNodePath(mailboxId, pathSeparator)
      ?? teamMailboxesTree.value.getNodePath(mailboxId, pathSeparator);
    log('BaseMailboxController::findNodePath():mailboxNodePath: $mailboxNodePath');
    return mailboxNodePath;
  }

  String? findNodePath(MailboxId mailboxId) {
    return findNodePathWithSeparator(mailboxId, '/');
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
        final mailboxNodePath = findNodePath(presentationMailbox.id);
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
  
  bool get teamMailboxesIsNotEmpty {
    return (teamMailboxesTree.value.root.childrenItems?.isNotEmpty ?? false)
      && !teamMailboxesTree.value.root.item.isTeamMailboxes;
  }

  MailboxNode get defaultRootNode => defaultMailboxTree.value.root;

  MailboxNode get personalRootNode => personalMailboxTree.value.root;

  MailboxNode get teamMailboxesRootNode => teamMailboxesTree.value.root;

  List<String> getListMailboxNameInParentMailbox(PresentationMailbox parentMailbox) {
    if (parentMailbox.parentId == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree.value.root.childrenItems ?? <MailboxNode>[])
        + (personalMailboxTree.value.root.childrenItems ?? <MailboxNode>[])
        + (teamMailboxesTree.value.root.childrenItems ?? <MailboxNode>[]);
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
      final mailboxNodeLocation = findMailboxNodeById(parentMailbox.parentId!);
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
      Get.dialog(
        PointerInterceptor(child: (EditTextDialogBuilder()
          ..key(const Key('rename_mailbox_dialog'))
          ..title(AppLocalizations.of(context).renameFolder)
          ..cancelText(AppLocalizations.of(context).cancel)
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
              ))
          )
          ..onConfirmButtonAction(
              AppLocalizations.of(context).rename,
              (value) => onRenameMailboxAction(presentationMailbox, MailboxName(value))
          )
        ).build()),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void moveMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    MailboxDashBoardController dashBoardController, {
    required MovingMailboxActionCallback onMovingMailboxAction
  }) async {
    final accountId = dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;
    if (accountId != null && session != null) {

      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.move,
        session,
        mailboxIdSelected: mailboxSelected.id
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
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
      Get.dialog(
        PointerInterceptor(
          child: (ConfirmDialogBuilder(imagePaths, useIconAsBasicLogo: true)
          ..key(const Key('confirm_dialog_delete_mailbox'))
          ..title(AppLocalizations.of(context).deleteFolders)
          ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_folder(presentationMailbox.getDisplayName(context)))
          ..onCloseButtonAction(() => popBack())
          ..onConfirmButtonAction(AppLocalizations.of(context).delete, () => onDeleteMailboxAction(presentationMailbox))
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack())
        ).build()),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  List<MailboxNode> getAncestorOfMailboxNode(MailboxNode mailboxNode) {
    final listAncestor = defaultMailboxTree.value.getAncestorList(mailboxNode)
      ?? personalMailboxTree.value.getAncestorList(mailboxNode)
      ?? teamMailboxesTree.value.getAncestorList(mailboxNode);
    return listAncestor ?? [];
  }

  SubscribeRequest? generateSubscribeRequest(
    MailboxId mailboxId,
    MailboxSubscribeState subscribeState,
    MailboxSubscribeAction subscribeAction
  ) {
    switch(subscribeState) {
      case MailboxSubscribeState.enabled:
        return _generateSubscribeRequestWhenSubscribeEnabled(mailboxId, subscribeAction);
      case MailboxSubscribeState.disabled:
        return _generateSubscribeRequestWhenSubscribeDisabled(mailboxId, subscribeAction);
    }
  }

  SubscribeRequest? _generateSubscribeRequestWhenSubscribeDisabled(
    MailboxId mailboxId,
    MailboxSubscribeAction subscribeAction
  ) {
    final mailboxNode = findMailboxNodeById(mailboxId);

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
    MailboxId mailboxId,
    MailboxSubscribeAction subscribeAction
  ) {
    final mailboxNode = findMailboxNodeById(mailboxId);

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

  void updateMailboxNameById(MailboxId mailboxId, MailboxName mailboxName) {
    UpdateMailboxNameAction(
      mailboxTrees: [defaultMailboxTree, personalMailboxTree, teamMailboxesTree],
      mailboxId: mailboxId,
      mailboxName: mailboxName,
    ).execute();
  }

  void updateUnreadCountOfMailboxById(
    MailboxId mailboxId, {
    required int unreadChanges,
  }) {
    UpdateMailboxUnreadCountAction(
      mailboxTrees: [defaultMailboxTree, personalMailboxTree, teamMailboxesTree],
      mailboxId: mailboxId,
      unreadChanges: unreadChanges,
    ).execute();
  }

  void clearUnreadCount(MailboxId mailboxId) {
    final mailboxTrees = [
      defaultMailboxTree,
      personalMailboxTree,
      teamMailboxesTree,
    ];

    for (var mailboxTree in mailboxTrees) {
      final selectedNode = mailboxTree.value.findNode((node) => node.item.id == mailboxId);
      if (selectedNode == null) continue;
      final currentUnreadCount = selectedNode.item.unreadEmails?.value.value.toInt();
      mailboxTree.value.updateMailboxUnreadCountById(
        mailboxId,
        -(currentUnreadCount ?? 0));
      mailboxTree.refresh();
      break;
    }
  }

  void updateMailboxTotalEmailsCountById(MailboxId mailboxId, int totalEmails) {
    UpdateMailboxTotalEmailsCountAction(
      mailboxTrees: [defaultMailboxTree, personalMailboxTree, teamMailboxesTree],
      mailboxId: mailboxId,
      totalEmailsCountChanged: totalEmails,
    ).execute();
  }
}