import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_submenu_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/label_sub_menu_mixin.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailContextMenuParams {
  final BuildContext context;
  final PresentationEmail email;
  final ImagePaths imagePaths;
  final bool isLabelAvailable;
  final List<Label>? labels;
  final RelativeRect? position;
  final OpenBottomSheetContextMenuAction openBottomSheetContextMenu;
  final OpenPopupMenuActionGroup openPopupMenu;
  final OnHandleEmailByActionType onHandleEmailByActionType;
  final OnSelectLabelAction onSelectLabelAction;

  EmailContextMenuParams({
    required this.context,
    required this.email,
    required this.imagePaths,
    required this.isLabelAvailable,
    required this.labels,
    required this.position,
    required this.openBottomSheetContextMenu,
    required this.openPopupMenu,
    required this.onHandleEmailByActionType,
    required this.onSelectLabelAction,
  });
}

mixin EmailMoreActionContextMenu on LabelSubMenuMixin {
  Future<void> openMoreActionContextMenu(EmailContextMenuParams params) async {
    final actions = _generateActionList(params);

    if (params.position == null) {
      return _openBottomSheet(params, actions);
    } else {
      return _openPopupMenu(params, actions);
    }
  }

  List<EmailActionType> _generateActionList(EmailContextMenuParams params) {
    final email = params.email;
    final mb = email.mailboxContain;

    final isRead = email.hasRead;
    final isDrafts = mb?.isDrafts ?? false;
    final isSpam = mb?.isSpam ?? false;
    final isTrash = mb?.isTrash ?? false;
    final isArchive = mb?.isArchive ?? false;
    final isTemplates = mb?.isTemplates ?? false;
    final isChildOfTeam = mb?.isChildOfTeamMailboxes ?? false;

    final canPermanentlyDelete = isDrafts || isSpam || isTrash;
    final shouldShowLabelAs =
        params.isLabelAvailable && (params.labels?.isNotEmpty ?? false);

    return [
      isRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
      EmailActionType.moveToMailbox,
      if (shouldShowLabelAs) EmailActionType.labelAs,
      canPermanentlyDelete
          ? EmailActionType.deletePermanently
          : EmailActionType.moveToTrash,
      if (PlatformInfo.isWeb) EmailActionType.openInNewTab,
      if (!isDrafts && !isChildOfTeam)
        isSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
      if (!isArchive) EmailActionType.archiveMessage,
      if (!isDrafts && !isTemplates) EmailActionType.editAsNewEmail,
    ];
  }

  Future<void> _openBottomSheet(
    EmailContextMenuParams params,
    List<EmailActionType> actions,
  ) {
    final appLocalizations = AppLocalizations.of(params.context);

    final contextMenuActions = actions.map((action) {
      return ContextItemEmailAction(
        action,
        appLocalizations,
        params.imagePaths,
        category: action.category,
      );
    }).toList();

    return params.openBottomSheetContextMenu(
      context: params.context,
      itemActions: contextMenuActions,
      useGroupedActions: true,
      onContextMenuActionClick: (menuAction) {
        popBack();
        params.onHandleEmailByActionType(
          menuAction.action,
          params.email,
          params.email.mailboxContain,
        );
      },
    );
  }

  Future<void> _openPopupMenu(
    EmailContextMenuParams params,
    List<EmailActionType> actions,
  ) {
    final appLocalizations = AppLocalizations.of(params.context);
    final submenuController = PopupSubmenuController();

    final popupMenuItemActions = actions.map((actionType) {
      return PopupMenuItemEmailAction(
        actionType,
        appLocalizations,
        params.imagePaths,
        category: actionType.category,
        submenu: buildLabelSubmenuForEmail(
          actionType: actionType,
          imagePaths: params.imagePaths,
          presentationEmail: params.email,
          labels: params.labels,
          onSelectLabelAction: (label, isSelected) {
            submenuController.hide();
            popBack();
            params.onSelectLabelAction(label, isSelected);
          },
        ),
      );
    }).toList();

    return params
        .openPopupMenu(
          params.context,
          params.position!,
          PopupMenuActionGroupWidget(
            actions: popupMenuItemActions,
            submenuController: submenuController,
            onActionSelected: (action) {
              if (shouldHandleAction(action.action)) {
                params.onHandleEmailByActionType(
                  action.action,
                  params.email,
                  params.email.mailboxContain,
                );
              }
            },
          ),
        )
        .whenComplete(submenuController.hide);
  }
}
