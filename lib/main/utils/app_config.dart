import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppConfig {
  static const int defaultMinInputLengthAutocomplete = 3;
  static const int warningAttachmentFileSizeInMegabytes = 10;

  static const String appDashboardConfigurationPath = "configurations/app_dashboard.json";
  static const String appFCMConfigurationPath = "configurations/env.fcm";
  static const String iOSKeychainSharingGroupId = 'KUT463DS29.com.linagora.ios.teammail.shared';
  static const String iOSKeychainSharingService = 'com.linagora.ios.teammail.sessions';
  static const String saasPlatform = 'saas';
  static const String linagoraPrivacyUrl = 'https://www.linagora.com/en/legal/privacy';
  static const String saasRegistrationUrl = 'https://sign-up.twake.app';
  static const String saasJmapServerUrl = 'https://jmap.twake.app';

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

  static String getForwardWarningMessage(BuildContext context) {
    final forwardWarningMessage = dotenv.get(
        'FORWARD_WARNING_MESSAGE',
        fallback: AppLocalizations.of(context).messageWarningDialogForForwardsToOtherDomains);

    if (forwardWarningMessage.trim().isEmpty) {
      return AppLocalizations.of(context).messageWarningDialogForForwardsToOtherDomains;
    }

    return forwardWarningMessage;
  }

  static String get _platformEnv => dotenv.get('PLATFORM', fallback: 'other');

  static bool get isSaasPlatForm => _platformEnv.toLowerCase() == saasPlatform;
}