import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
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

  static String? get fcmVapidPublicKey => PlatformInfo.isWeb ? AppConfig.fcmVapidPublicKeyWeb : null;

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

  static TextDirection getCurrentDirection(BuildContext context) => Directionality.maybeOf(context) ?? TextDirection.ltr;

  static bool isEmailLocalhost(String email) {
    return  RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@localhost$').hasMatch(email);
  }

  static void copyEmailAddressToClipboard(BuildContext context, String emailAddress) {
    Clipboard.setData(ClipboardData(text: emailAddress)).then((_){
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).email_address_copied_to_clipboard))
      );
    });
  }
}