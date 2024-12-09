
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/string_convert.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

mixin LauncherApplicationMixin {

  Future<void> launchApplication({
    String? androidPackageId,
    String? iosScheme,
    String? iosStoreLink,
    Uri? uri,
  }) async {
    try {
      if (PlatformInfo.isWeb && uri != null) {
        await openWebApplication(uri);
      } else if (PlatformInfo.isAndroid && androidPackageId != null) {
        await openAndroidApplication(androidPackageId);
      } else if (PlatformInfo.isIOS &&
          (iosScheme != null || iosStoreLink != null)) {
        await openIOSApplication(
          iosScheme,
          iosStoreLink,
        );
      } else if (uri != null) {
        await openOtherApplication(uri);
      }
    } catch (e) {
      logError('LauncherApplicationMixin::launchApplication:Exception = $e');
    }
  }

  Future<void> openAndroidApplication(String androidPackageId) async {
    await LaunchApp.openApp(androidPackageName: androidPackageId);
  }

  Future<void> openIOSApplication(String? iosScheme, String? iosStoreLink) async {
    await LaunchApp.openApp(
      iosUrlScheme: iosScheme != null
        ? StringConvert.toUrlScheme(iosScheme)
        : null,
      appStoreLink: iosStoreLink,
    );
  }

  Future<void> openWebApplication(Uri uri) async {
    await launcher.launchUrl(uri);
  }

  Future<void> openOtherApplication(Uri uri) async {
    await launcher.launchUrl(
      uri,
      mode: launcher.LaunchMode.externalApplication,
    );
  }
}