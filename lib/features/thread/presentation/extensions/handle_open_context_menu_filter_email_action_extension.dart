import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/popup_menu_item_filter_message_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleOpenContextMenuFilterEmailActionExtension on ThreadController {
  void handleOpenContextMenuFilterEmailAction(
    BuildContext context,
    RelativeRect position,
    FilterMessageOption selectedFilterOption,
  ) {
    final popupMenuItems = [
      FilterMessageOption.attachments,
      FilterMessageOption.unread,
      FilterMessageOption.starred,
    ].map((filterOption) {
      return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: PopupMenuItemActionWidget(
          menuAction: PopupMenuItemFilterMessageAction(
            filterOption,
            selectedFilterOption,
            AppLocalizations.of(context),
            imagePaths,
          ),
          menuActionClick: (menuAction) {
            popBack();
            filterMessagesAction(menuAction.action);
          },
        ),
      );
    }).toList();

    openPopupMenuAction(context, position, popupMenuItems);
  }
}
