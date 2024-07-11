import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension TokenOidcExtension on TokenOIDC {
  TokenOidcCache toTokenOidcCache() {
    return TokenOidcCache(
      token: token,
      tokenId: tokenId.uuid,
      refreshToken: refreshToken,
      authority: authority,
      expiredTime: expiredTime
    );
  }

  bool isTokenValid() => token.isNotEmpty && tokenId.uuid.isNotEmpty;

  String get tokenIdHash => tokenId.uuid.hashCode.toString();

  bool get isExpired {
    if (expiredTime != null) {
      final currentTime = DateTime.now();
      log('TokenOIDC::isExpired(): currentTime: $currentTime | expiredTime: $expiredTime');
      return expiredTime!.isBefore(currentTime);
    }
    return false;
  }

  String get authenticationHeader => 'Bearer $token';

  OIDCConfiguration get oidcConfiguration => OIDCConfiguration(
    authority: authority,
    clientId: OIDCConstant.clientId,
    scopes: AppConfig.oidcScopes
  );
}