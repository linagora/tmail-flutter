import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_submenu_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEmailMoreActionExtension on SearchEmailController {
  Future<void> handleEmailMoreAction(
    BuildContext context,
    PresentationEmail presentationEmail,
    RelativeRect? position,
  ) {
    final mailboxContain = presentationEmail.mailboxContain;
    final isDrafts = mailboxContain?.isDrafts ?? false;
    final isSpam = mailboxContain?.isSpam ?? false;
    final isRead = presentationEmail.hasRead;
    final isTrash = mailboxContain?.isTrash ?? false;
    final canPermanentlyDelete = isDrafts || isSpam || isTrash;
    final isLabelAvailable = mailboxDashBoardController.isLabelAvailable;
    final listLabels = mailboxDashBoardController.labelController.labels;
    final shouldShowLabelAs = isLabelAvailable && listLabels.isNotEmpty;

    final listEmailActions = [
      isRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
      EmailActionType.moveToMailbox,
      if (shouldShowLabelAs) EmailActionType.labelAs,
      canPermanentlyDelete ? EmailActionType.deletePermanently : EmailActionType.moveToTrash,
      isSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
      if (!isDrafts) EmailActionType.editAsNewEmail,
    ];

    if (listEmailActions.isEmpty) return Future.value();

    if (position == null) {
      final contextMenuActions = listEmailActions
          .map((action) => ContextItemEmailAction(
                action,
                AppLocalizations.of(context),
                imagePaths,
                category: action.category,
              ))
          .toList();

      return openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          popBack();
          pressEmailAction(
            context,
            menuAction.action,
            presentationEmail,
            mailboxContain: mailboxContain,
          );
        },
        useGroupedActions: true,
      );
    } else {
      final submenuController = PopupSubmenuController();

      final popupMenuItemEmailActions = listEmailActions.map((actionType) {
        return PopupMenuItemEmailAction(
          actionType,
          AppLocalizations.of(context),
          imagePaths,
          category: actionType.category,
          submenu: buildLabelSubmenuForEmail(
            actionType: actionType,
            imagePaths: imagePaths,
            presentationEmail: presentationEmail,
            labels: listLabels,
            onSelectLabelAction: (label, isSelected) {
              submenuController.hide();
              popBack();
            },
          ),
        );
      }).toList();

      final popupMenuWidget = PopupMenuActionGroupWidget(
        actions: popupMenuItemEmailActions,
        submenuController: submenuController,
        onActionSelected: (action) {
          if (shouldHandleAction(action.action)) {
            pressEmailAction(
              context,
              action.action,
              presentationEmail,
              mailboxContain: mailboxContain,
            );
          }
        },
      );

      return popupMenuWidget.show(
        context,
        position,
      ).whenComplete(submenuController.hide);
    }
  }
}
