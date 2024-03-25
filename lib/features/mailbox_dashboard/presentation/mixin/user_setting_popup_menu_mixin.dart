
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/popup_menu/popup_menu_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin UserSettingPopupMenuMixin {
  final _imagePaths = Get.find<ImagePaths>();

  List<PopupMenuEntry> popupMenuUserSettingActionTile(
    BuildContext context,
    UserName? userName,
    {
      VoidCallback? onLogoutAction,
      VoidCallback? onSettingAction
    }
  ) {
    return [
      if (userName != null)
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 300,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                userName.value,
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
          _popupMenuAction(
            context: context,
            title: AppLocalizations.of(context).manage_account,
            icon: _imagePaths.icSetting,
            onCallBack: onSettingAction
          ),
        ],
      if (onLogoutAction != null)
        ...[
          const PopupMenuDivider(height: 0.5),
          _popupMenuAction(
            context: context,
            title: AppLocalizations.of(context).sign_out,
            icon: _imagePaths.icLogout,
            onCallBack: onLogoutAction
          ),
        ]
    ];
  }

  PopupMenuEntry _popupMenuAction({
    required BuildContext context,
    required String title,
    required String icon,
    VoidCallback? onCallBack
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: PopupMenuItemWidget(
        name: title,
        icon: icon,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w500
        ),
        space: 12,
        onCallbackAction: onCallBack,
      ),
    );
  }
}