
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/slogan_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/launcher_application_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';

class AppListDashboardItem extends StatelessWidget with LauncherApplicationMixin {

  final AppLinagoraEcosystem app;
  final ImagePaths imagePaths;

  const AppListDashboardItem({
    super.key,
    required this.app,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return SloganBuilder(
      sizeLogo: 32,
      paddingText: const EdgeInsetsDirectional.only(start: 12),
      text: app.appName,
      textAlign: TextAlign.center,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColor.colorNameEmail,
      ),
      logo: app.getIconPath(imagePaths),
      onTapCallback: _handleOpenApp,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 20),
      hoverColor: AppColor.colorBgMailboxSelected
    );
  }

  Future<void> _handleOpenApp() async {
    await launchApplication(
      androidPackageId: app.androidPackageId,
      iosScheme: app.iosUrlScheme,
      iosStoreLink: app.iosAppStoreLink,
      uri: app.appRedirectLink,
    );
  }
}
