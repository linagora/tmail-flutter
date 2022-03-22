
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin UserSettingPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  void openUserSettingAction(BuildContext context, RelativeRect? position, List<PopupMenuEntry> popupMenuItems) async {
    await showMenu(
        context: context,
        position: position ?? RelativeRect.fromLTRB(16, 40, 16, 16),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        items: popupMenuItems);
  }

  List<PopupMenuEntry> popupMenuUserSettingActionTile(BuildContext context, Function? onCallBack) {
    return [
      PopupMenuItem(padding: EdgeInsets.symmetric(horizontal: 8), child: logoutAction(context, onCallBack)),
    ];
  }

  Widget logoutAction(BuildContext context, Function? onCallBack) {
    return (AppActionSheetActionBuilder(
          Key('logout_action'),
          SvgPicture.asset(_imagePaths.icCloseMailbox, color: AppColor.colorTextButton, fit: BoxFit.fill),
          AppLocalizations.of(context).logout,
          iconLeftPadding:EdgeInsets.only(right: 12))
        ..onActionClick((option) => onCallBack?.call()))
      .build();
  }
}