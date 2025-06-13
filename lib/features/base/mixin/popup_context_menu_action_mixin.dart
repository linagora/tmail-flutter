
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/bottom_popup/cupertino_action_sheet_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin PopupContextMenuActionMixin {

  void openContextMenuAction(
    BuildContext context,
    List<Widget> actionTiles,
    {
      Widget? cancelButton,
      Key? key,
    }
  ) async {
    await (CupertinoActionSheetBuilder(context, key: key)
        ..addTiles(actionTiles)
        ..addCancelButton(cancelButton ?? buildCancelButton(context)))
      .show();
  }

  Future<void> openPopupMenuAction(
    BuildContext context,
    RelativeRect? position,
    List<PopupMenuEntry> popupMenuItems,
  ) async {
    await showMenu(
      context: context,
      position: position ?? const RelativeRect.fromLTRB(16, 40, 16, 16),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      menuPadding: const EdgeInsets.only(top: 8, bottom: 8),
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      constraints: const BoxConstraints(maxWidth: 300, minWidth: 178),
      items: popupMenuItems,
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