import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {

  static const String envFileName = 'env.file';

  static Future<void> loadEnvFile()  {
    return dotenv.load(fileName: envFileName);
  }

  static Future<void> loadFcmConfigFile()  {
    return dotenv.load(fileName: AppConfig.appFCMConfigurationPath);
  }

  static Future<void> launchLink(String url, {bool isNewTab = true}) async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }
}