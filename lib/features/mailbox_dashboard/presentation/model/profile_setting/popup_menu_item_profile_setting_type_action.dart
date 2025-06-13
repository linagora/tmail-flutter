import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PopupMenuItemProfileSettingTypeAction
    extends PopupMenuItemActionRequiredIcon<ProfileSettingActionType> {
  final AppLocalizations appLocalizations;
  final ImagePaths imagePaths;

  PopupMenuItemProfileSettingTypeAction(
    super.action,
    this.appLocalizations,
    this.imagePaths,
  );

  @override
  String get actionIcon => action.getIcon(imagePaths);

  @override
  String get actionName => action.getTitle(appLocalizations);

  @override
  Color get actionIconColor => AppColor.gray686E76;

  @override
  EdgeInsetsGeometry get itemPadding => const EdgeInsets.symmetric(horizontal: 16);
}
