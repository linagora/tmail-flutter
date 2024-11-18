import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';

class DeepLinksManager {
  Future<DeepLinkData?> getDeepLinkData() async {
    final uriLink = await AppLinks().getInitialLink();
    if (uriLink == null) return null;

    final deepLinkData = parseDeepLink(uriLink.toString());
    return deepLinkData;
  }

  DeepLinkData? parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url.replaceFirst(OIDCConstant.twakeWorkplaceUrlScheme, 'https'));

      final accessToken = uri.queryParameters['access_token'] ?? '';
      final refreshToken = uri.queryParameters['refresh_token'] ?? '';
      final idToken = uri.queryParameters['id_token'] ?? '';
      final expiresInStr = uri.queryParameters['expires_in'] ?? '';
      final username = uri.queryParameters['username'] ?? '';

      final expiresIn = int.tryParse(expiresInStr);

      return DeepLinkData(
        path: uri.path,
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        expiresIn: expiresIn,
        username: username,
      );
    } catch (e) {
      logError('DeepLinksManager::parseDeepLink:Exception = $e');
      return null;
    }
  }
}