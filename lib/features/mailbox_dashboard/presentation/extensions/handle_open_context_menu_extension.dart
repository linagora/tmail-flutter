import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleOpenContextMenuExtension on MailboxDashBoardController {
  Future<void> openBottomSheetContextMenu({
    required BuildContext context,
    required List<ContextMenuItemAction> itemActions,
    required OnContextMenuActionClick onContextMenuActionClick,
    Key? key,
    bool useGroupedActions = false,
  }) {
    if (PlatformInfo.isWeb) {
      isContextMenuOpened.value = true;
    }
   return openBottomSheetContextMenuAction(
     context: context,
     itemActions: itemActions,
     onContextMenuActionClick: onContextMenuActionClick,
     key: key,
     useGroupedActions: useGroupedActions,
   ).whenComplete(() {
     if (PlatformInfo.isWeb) {
       isContextMenuOpened.value = false;
     }
   });
  }

  Future<void> openPopupMenu(
    BuildContext context,
    RelativeRect position,
    List<PopupMenuEntry> popupMenuItems,
  ) {
    if (PlatformInfo.isWeb) {
      isPopupMenuOpened.value = true;
    }
    return openPopupMenuAction(
      context,
      position,
      popupMenuItems,
    ).whenComplete(() {
      if (PlatformInfo.isWeb) {
        isPopupMenuOpened.value = false;
      }
    });
  }

  Future<void> openPopupMenuActionGroup(
    BuildContext context,
    RelativeRect position,
    PopupMenuActionGroupWidget popupMenuWidget,
  ) {
    if (PlatformInfo.isWeb) {
      isPopupMenuOpened.value = true;
    }
    return popupMenuWidget.show(
      context,
      position,
    ).whenComplete(() {
      if (PlatformInfo.isWeb) {
        isPopupMenuOpened.value = false;
      }
    });
  }
}
