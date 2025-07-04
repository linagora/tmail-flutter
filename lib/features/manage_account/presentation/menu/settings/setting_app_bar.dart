import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/setting_first_level_app_bar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/universal_setting_app_bar.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';

class SettingAppBar extends StatelessWidget {
  final SettingsPageLevel pageLevel;
  final AccountMenuItem accountMenuItem;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback onBackAction;
  final VoidCallback? onExportTraceLogAction;

  const SettingAppBar({
    super.key,
    required this.pageLevel,
    required this.accountMenuItem,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onBackAction,
    this.onExportTraceLogAction,
  });

  @override
  Widget build(BuildContext context) {
    if (pageLevel == SettingsPageLevel.universal) {
      return UniversalSettingAppBar(
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        onBackAction: onBackAction,
        onExportTraceLogAction: onExportTraceLogAction,
      );
    } else {
      return SettingFirstLevelAppBar(
        accountMenuItem: accountMenuItem,
        imagePaths: imagePaths,
        responsiveUtils: responsiveUtils,
        onBackAction: onBackAction,
      );
    }
  }
}
