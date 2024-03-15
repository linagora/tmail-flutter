import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';

class AppConfig {
  static const int limitCharToStartSearch = 3;
  static const int warningAttachmentFileSizeInMegabytes = 10;

  static const String appDashboardConfigurationPath = "configurations/app_dashboard.json";
  static const String appFCMConfigurationPath = "configurations/env.fcm";
  static const String iOSKeychainSharingGroupId = 'KUT463DS29.com.linagora.ios.teammail.shared';
  static const String iOSKeychainSharingService = 'com.linagora.ios.teammail.sessions';

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
  static String get fcmVapidPublicKeyWeb => dotenv.get('FIREBASE_WEB_VAPID_PUBLIC_KEY', fallback: '');
  static List<String> get oidcScopes {
    try {
      final envScopes = dotenv.get('OIDC_SCOPES', fallback: '');

      if (envScopes.isNotEmpty) {
        return envScopes.split(',');
      }

      return OIDCConstant.oidcScope;
    } catch (e) {
      return OIDCConstant.oidcScope;
    }
  }
}