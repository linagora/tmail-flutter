
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin UserSettingPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  List<PopupMenuEntry> popupMenuUserSettingActionTile(BuildContext context, UserProfile? userProfile,
      {Function? onLogoutAction, Function? onSettingAction}) {
    return [
      PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _userInformation(context, userProfile)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _settingAction(context, onSettingAction)),
      const PopupMenuDivider(height: 0.5),
      PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _logoutAction(context, onLogoutAction)),
    ];
  }

  Widget _userInformation(BuildContext context, UserProfile? userProfile) {
    if (userProfile != null) {
      return SizedBox(
        width: 300,
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(userProfile.email, maxLines: 1, style: const TextStyle(
                fontSize: 15,
                color: AppColor.colorHintSearchBar,
                fontWeight: FontWeight.normal))),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _settingAction(BuildContext context, Function? onCallBack) {
    return PopupMenuItemWidget(
        _imagePaths.icSetting,
        AppLocalizations.of(context).settings,
        () => onCallBack?.call());
  }

  Widget _logoutAction(BuildContext context, Function? onCallBack) {
    return PopupMenuItemWidget(
        _imagePaths.icLogout,
        AppLocalizations.of(context).sign_out,
        () => onCallBack?.call());
  }
}