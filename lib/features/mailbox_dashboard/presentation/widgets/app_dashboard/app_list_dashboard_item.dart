import 'dart:io';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/slogan_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_app.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class AppListDashboardItem extends StatelessWidget {

  final LinagoraApp app;

  const AppListDashboardItem(this.app, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return SloganBuilder(
      sizeLogo: 32,
      paddingText: const EdgeInsetsDirectional.only(start: 12),
      text: app.appName,
      textAlign: TextAlign.center,
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorNameEmail),
      logo: app.iconName?.isNotEmpty == true
        ? imagePaths.getConfigurationImagePath(app.iconName!)
        : null,
      publicLogoUri: app.publicIconUri,
      onTapCallback: () => _openApp(context, app),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 20),
      hoverColor: AppColor.colorBgMailboxSelected
    );
  }

  void _openApp(BuildContext context, LinagoraApp app) async {
    if (PlatformInfo.isWeb) {
      if (await launcher.canLaunchUrl(app.appUri)) {
        await launcher.launchUrl(app.appUri);
      }
    } else if (Platform.isAndroid && app.androidPackageId?.isNotEmpty == true) {
      await LaunchApp.openApp(androidPackageName: app.androidPackageId);
    } else if (Platform.isIOS && app.iosUrlScheme?.isNotEmpty == true) {
      await LaunchApp.openApp(
        iosUrlScheme: '${app.iosUrlScheme}://',
        appStoreLink: app.iosAppStoreLink
      );
    } else {
      if (await launcher.canLaunchUrl(app.appUri)) {
        await launcher.launchUrl(
          app.appUri,
          mode: launcher.LaunchMode.externalApplication
        );
      }
    }
  }
}
