
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin PopupContextMenuActionMixin {

  void openContextMenuAction(BuildContext context, List<Widget> actionTiles, {Widget? cancelButton}) {
    (CupertinoActionSheetBuilder(context)
        ..addTiles(actionTiles)
        ..addCancelButton(cancelButton ?? buildCancelButton(context)))
      .show();
  }

  void openPopupMenuAction(BuildContext context, RelativeRect? position, List<PopupMenuEntry> popupMenuItems) async {
    await showMenu(
        context: context,
        position: position ?? RelativeRect.fromLTRB(16, 40, 16, 16),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        items: popupMenuItems);
  }

  Widget buildCancelButton(BuildContext context) {
    return CupertinoActionSheetAction(
      child: Text(
          AppLocalizations.of(context).cancel,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: AppColor.colorTextButton)),
      onPressed: () => popBack(),
    );
  }
}