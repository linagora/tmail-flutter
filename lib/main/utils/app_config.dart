import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.get('SERVER_URL', fallback: '');
  static String get domainRedirectUrl => dotenv.get('DOMAIN_REDIRECT_URL', fallback: '');
  static String get webOidcClientId => dotenv.get('WEB_OIDC_CLIENT_ID', fallback: '');
  static bool get appGridDashboardAvailable {
    final supported = dotenv.get('APP_GRID_AVAILABLE', fallback: 'unsupported');
    if (supported == 'supported') {
      return true;
    }
    return false;
  }
  static String appDashboardConfigurationPath = "configurations/app_dashboard.json";
  static bool get fcmAvailable {
    final supportedOtherPlatform = dotenv.get('FCM_AVAILABLE', fallback: 'unsupported');
    final supportedIOSPlatform = dotenv.get('IOS_FCM', fallback: 'unsupported');
    if (kIsWeb) return supportedOtherPlatform == 'supported';
    if (Platform.isIOS) {
      return supportedIOSPlatform == 'supported';
    } else {
      return supportedOtherPlatform == 'supported';
    }
  }
  static String appFCMConfigurationPath = "configurations/env.fcm";

  static String get fcmVapidPublicKeyWeb => dotenv.get('FIREBASE_WEB_VAPID_PUBLIC_KEY', fallback: '');
}