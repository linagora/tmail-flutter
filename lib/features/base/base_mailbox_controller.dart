import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:core/presentation/views/modal_sheets/edit_text_modal_sheet_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

abstract class BaseMailboxController extends BaseController {
  final TreeBuilder _treeBuilder;
  final VerifyNameInteractor verifyNameInteractor;
  final GetAllMailboxInteractor? getAllMailboxInteractor;
  final RefreshAllMailboxInteractor? refreshAllMailboxInteractor;
  jmap.State? currentMailboxState;

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

  Future buildTree(
      List<PresentationMailbox> allMailbox,
      {MailboxId? mailboxIdSelected}
  ) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUI(
        allMailbox,
        mailboxIdSelected: mailboxIdSelected);
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = tupleTree.value1;
    personalMailboxTree.value = tupleTree.value2;
    teamMailboxesTree.value = tupleTree.value3;
    allMailboxes = tupleTree.value4;
  }

  Future refreshTree(List<PresentationMailbox> allMailbox) async {
    allMailboxes = allMailbox;
    final tupleTree = await _treeBuilder.generateMailboxTreeInUIAfterRefreshChanges(
      allMailbox, 
      defaultMailboxTree.value, 
      personalMailboxTree.value,
      teamMailboxesTree.value);
    defaultMailboxTree.firstRebuild = true;
    personalMailboxTree.firstRebuild = true;
    teamMailboxesTree.firstRebuild = true;
    defaultMailboxTree.value = tupleTree.value1;
    personalMailboxTree.value = tupleTree.value2;
    teamMailboxesTree.value = tupleTree.value3;
  }

  void toggleMailboxFolder(MailboxNode selectedMailboxNode) {
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
    }

    if (teamMailboxesTree.value.updateExpandedNode(selectedMailboxNode, newExpandMode) != null) {
      log('toggleMailboxFolder() refresh teamMailboxesTree');
      teamMailboxesTree.refresh();
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
    final mailboxPersonal = personalMailboxTree.value.findNode((node) => node.item.id == mailboxId);
    if (mailboxNode != null) {
      return mailboxNode;
    }
    
    if (mailboxPersonal != null) {
      return mailboxPersonal;
    }
    return teamMailboxesTree.value.findNode((node) => node.item.id == mailboxId);
  }

  String? findNodePath(MailboxId mailboxId) {
    var mailboxNodePath = defaultMailboxTree.value.getNodePath(mailboxId)
      ?? personalMailboxTree.value.getNodePath(mailboxId)
      ?? teamMailboxesTree.value.getNodePath(mailboxId);
    log('BaseMailboxController::findNodePath():mailboxNodePath: $mailboxNodePath');
    return mailboxNodePath;
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
      DuplicateNameValidator(listMailboxName),
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
    required Function(PresentationMailbox mailbox, MailboxName newMailboxName) onRenameMailboxAction
  }) {
    final listMailboxName = getListMailboxNameInParentMailbox(presentationMailbox);

    if (responsiveUtils.isMobile(context)) {
      (EditTextModalSheetBuilder()
        ..key(const Key('rename_mailbox_dialog'))
        ..title(AppLocalizations.of(context).rename_mailbox)
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
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (context) =>
          PointerInterceptor(child: (EditTextDialogBuilder()
            ..key(const Key('rename_mailbox_dialog'))
            ..title(AppLocalizations.of(context).rename_mailbox)
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
          ).build())
      );
    }
  }

  void moveMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    MailboxDashBoardController dashBoardController, {
    required Function(PresentationMailbox mailboxSelected, PresentationMailbox? destinationMailbox) onMovingMailboxAction
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

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
          context: context,
          arguments: arguments,
          onSelectedMailbox: (destinationMailbox) {
            onMovingMailboxAction(
              mailboxSelected,
              destinationMailbox == PresentationMailbox.unifiedMailbox
                ? null
                : destinationMailbox
            );
          }
        );
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

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
  }

  void openConfirmationDialogDeleteMailboxAction(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths,
    PresentationMailbox presentationMailbox, {
    required Function(PresentationMailbox mailbox) onDeleteMailboxAction
  }) {
    if (responsiveUtils.isLandscapeMobile(context) || responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () => onDeleteMailboxAction(presentationMailbox))
      ).show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (context) => PointerInterceptor(
          child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_delete_mailbox'))
          ..title(AppLocalizations.of(context).delete_mailboxes)
          ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog
          ))
          ..onCloseButtonAction(() => popBack())
          ..onConfirmButtonAction(AppLocalizations.of(context).delete, () => onDeleteMailboxAction(presentationMailbox))
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack())
        ).build())
      );
    }
  }

  SubscribeRequest? generateSubscribeRequest(
    MailboxId mailboxId,
    MailboxSubscribeState subscribeState,
    MailboxSubscribeAction subscribeAction
  ) {
    final mailboxNode = findMailboxNodeById(mailboxId);

    if (mailboxNode != null) {
      if (mailboxNode.hasChildren()) {
        final listDescendantMailboxIds = mailboxNode.descendantsAsList().mailboxIds;
        return SubscribeMultipleMailboxRequest(mailboxId, listDescendantMailboxIds, subscribeState, subscribeAction);
      } else {
        return SubscribeMailboxRequest(mailboxId, subscribeState, subscribeAction);
      }
    }
    return null;
  }

  void getAllMailbox(Session session, AccountId accountId) async {
    if (getAllMailboxInteractor != null) {
      consumeState(getAllMailboxInteractor!.execute(session, accountId));
    }
  }

  void refreshMailboxChanges(
    Session session,
    AccountId accountId,
    jmap.State currentMailboxState
  ) {
    if (refreshAllMailboxInteractor != null) {
      log('BaseMailboxController::refreshMailboxChanges(): currentMailboxState: $currentMailboxState');
      final newMailboxState = currentMailboxState;
      log('BaseMailboxController::refreshMailboxChanges(): newMailboxState: $newMailboxState');
      consumeState(refreshAllMailboxInteractor!.execute(session, accountId, newMailboxState));
    }
  }
}