import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;

class AppUtils {

  static const String envFileName = 'env.file';

  static Future<void> loadEnvFile()  {
    return dotenv.load(fileName: envFileName);
  }

  static Future<void> loadFcmConfigFileToEnv({Map<String, String>? currentMapEnvData})  {
    return dotenv.load(
      fileName: AppConfig.appFCMConfigurationPath,
      mergeWith: currentMapEnvData ?? {}
    );
  }

  static Future<void> launchLink(String url, {bool isNewTab = true}) async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }

  static String? get fcmVapidPublicKey => BuildUtils.isWeb ? AppConfig.fcmVapidPublicKeyWeb : null;

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

  static TextDirection getCurrentDirection(BuildContext context) =>
    isDirectionRTL(context) ? TextDirection.rtl : TextDirection.ltr;

  static bool isEmailLocalhost(String email) {
    return  RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@localhost$').hasMatch(email);
  }
}