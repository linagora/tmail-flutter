import 'package:flutter/material.dart';
 import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
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

    final listEmailActions = [
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
              ))
          .toList();

      return openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          pressEmailAction(
            context,
            menuAction.action,
            presentationEmail,
            mailboxContain: mailboxContain,
          );
        },
      );
    } else {
      final popupMenuItems = listEmailActions.map((actionType) {
        return PopupMenuItem(
          padding: EdgeInsets.zero,
          child: PopupMenuItemActionWidget(
            menuAction: PopupMenuItemEmailAction(
              actionType,
              AppLocalizations.of(context),
              imagePaths,
            ),
            menuActionClick: (menuAction) {
              popBack();
              pressEmailAction(
                context,
                menuAction.action,
                presentationEmail,
                mailboxContain: mailboxContain,
              );
            },
          ),
        );
      }).toList();

      return openPopupMenuAction(context, position, popupMenuItems);
    }
  }
}
