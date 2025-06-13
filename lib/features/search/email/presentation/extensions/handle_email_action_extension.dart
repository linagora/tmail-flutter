import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEmailActionExtension on SearchEmailController {
  void handleEmailMoreActionClick(
    BuildContext context,
    RelativeRect position,
    PresentationEmail presentationEmail,
  ) {
    final mailboxContain = presentationEmail.mailboxContain;
    final isDrafts = mailboxContain?.isDrafts ?? false;
    final isSpam = mailboxContain?.isSpam ?? false;

    final popupMenuItems = [
      isSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
      if (isDrafts == false) EmailActionType.editAsNewEmail,
    ].map((actionType) {
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

    openPopupMenuAction(context, position, popupMenuItems);
  }
}
