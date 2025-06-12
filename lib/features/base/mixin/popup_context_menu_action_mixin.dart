
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_dialog_view.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin PopupContextMenuActionMixin {

  void openContextMenuAction(
    BuildContext context,
    List<Widget> actionTiles,
    {
      Widget? cancelButton,
      Key? key,
      List<ContextMenuItemAction>? itemActions,
      OnContextMenuActionClick? onContextMenuActionClick,
    }
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) {
        return ColoredBox(
          color: Colors.white,
          child: ContextMenuDialogView(
            actions: itemActions ?? [],
            onContextMenuActionClick: (menuAction) =>
                onContextMenuActionClick?.call(menuAction),
          ),
        );
      },
    );
  }

  void openPopupMenuAction(
    BuildContext context,
    RelativeRect? position,
    List<PopupMenuEntry> popupMenuItems,
    {
      double? radius,
    }
  ) async {
    await showMenu(
      context: context,
      position: position ?? const RelativeRect.fromLTRB(16, 40, 16, 16),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 16))
      ),
      items: popupMenuItems
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return MouseRegion(
      cursor: PlatformInfo.isWeb ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
      child: CupertinoActionSheetAction(
        child: Text(
            AppLocalizations.of(context).cancel,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorTextButton)),
        onPressed: () => popBack(),
      ),
    );
  }
}