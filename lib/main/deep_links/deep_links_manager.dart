import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';

class DeepLinksManager {
  Future<DeepLinkData?> getDeepLinkData() async {
    final uriLink = await AppLinks().getInitialLink();
    log('DeepLinksManager::getDeepLinkData:uriLink = $uriLink');
    if (uriLink == null) return null;

    final deepLinkData = parseDeepLink(uriLink.toString());
    return deepLinkData;
  }

  DeepLinkData? parseDeepLink(String url) {
    try {
      final updatedUrl = url.replaceFirst(
        OIDCConstant.twakeWorkplaceUrlScheme,
        'https',
      );
      final uri = Uri.parse(updatedUrl);
      final action = uri.host;
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final idToken = uri.queryParameters['id_token'];
      final expiresInStr = uri.queryParameters['expires_in'];
      final username = uri.queryParameters['username'];

      final expiresIn = expiresInStr != null
        ? int.tryParse(expiresInStr)
        : null;

      return DeepLinkData(
        action: action,
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