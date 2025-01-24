
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/popup_menu/popup_menu_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin UserSettingPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  List<PopupMenuEntry> popupMenuUserSettingActionTile(
    BuildContext context,
    String? currentUserEmail,
    {
      Function? onLogoutAction,
      Function? onSettingAction
    }
  ) {
    return [
      if(currentUserEmail != null)
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 300,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: SelectableText(
                currentUserEmail,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColor.colorHintSearchBar,
                  fontWeight: FontWeight.normal
                )
              )
            ),
          )
        ),
      if (onSettingAction != null)
        ...[
          const PopupMenuDivider(height: 0.5),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: _settingAction(context, onSettingAction)
          ),
          const PopupMenuDivider(height: 0.5),
        ],
      if (onLogoutAction != null)
        ...[
          const PopupMenuDivider(height: 0.5),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: _logoutAction(context, onLogoutAction)
          ),
        ]
    ];
  }

  Widget _settingAction(BuildContext context, Function? onCallBack) {
    return PopupMenuItemWidget(
        _imagePaths.icSetting,
        AppLocalizations.of(context).manage_account,
        () => onCallBack?.call());
  }

  Widget _logoutAction(BuildContext context, Function? onCallBack) {
    return PopupMenuItemWidget(
        _imagePaths.icLogout,
        AppLocalizations.of(context).sign_out,
        () => onCallBack?.call());
  }
}