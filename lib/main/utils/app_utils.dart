import 'package:core/core.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

class AppUtils {
  const AppUtils._();

  static Future<void> loadEnvFile() async {
    await dotenv.load(fileName: AppConfig.envFileName);
    final mapEnvData = Map<String, String>.from(dotenv.env);
   try {
     await loadFcmConfigFileToEnv(currentMapEnvData: mapEnvData);
   } catch (e) {
     logError('AppUtils::loadEnvFile:loadFcmConfigFileToEnv: Exception = $e');
     await dotenv.load(fileName: AppConfig.envFileName);
   }
  }

  static Future<void> loadFcmConfigFileToEnv({Map<String, String>? currentMapEnvData})  {
    return dotenv.load(
      fileName: AppConfig.appFCMConfigurationPath,
      mergeWith: currentMapEnvData ?? {}
    );
  }

  static void launchLink(String url, {bool isNewTab = true}) {
    if (PlatformInfo.isWeb) {
      html.window.open(url, isNewTab ? '_blank' : '_self');
    } else {
      launchUrl(
        Uri.parse(url),
        webOnlyWindowName: isNewTab ? '_blank' : '_self',
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

  static TextDirection getCurrentDirection(BuildContext context) => Directionality.maybeOf(context) ?? TextDirection.ltr;

  static bool isEmailLocalhost(String email) {
    return  RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@localhost$').hasMatch(email);
  }

  static void copyEmailAddressToClipboard(BuildContext context, String emailAddress) {
    Clipboard.setData(ClipboardData(text: emailAddress)).then((_){
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).email_address_copied_to_clipboard))
      );
    });
  }

  static date_format.DateLocale getCurrentDateLocale() {
    final currentLanguageCode = Get.locale?.languageCode;
    if (currentLanguageCode == LanguageCodeConstants.french) {
      return const date_format.FrenchDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.english) {
      return const date_format.EnglishDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.vietnamese) {
      return const date_format.VietnameseDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.russian) {
      return const date_format.RussianDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.arabic) {
      return const date_format.ArabicDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.italian) {
      return const date_format.ItalianDateLocale();
    } else if (currentLanguageCode == LanguageCodeConstants.german) {
      return const date_format.GermanDateLocale();
    } else {
      return const date_format.EnglishDateLocale();
    }
  }

  static String getTimeZone() {
    final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    final timeZoneOffsetAsString = timeZoneOffset >= 0 ? '+$timeZoneOffset' : '$timeZoneOffset';
    return 'GMT$timeZoneOffsetAsString';
  }
}
