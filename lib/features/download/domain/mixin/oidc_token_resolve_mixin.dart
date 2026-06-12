import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';

mixin OidcTokenResolveMixin {
  AuthenticationOIDCRepository get authOIDCRepository;

  Future<TokenOIDC> resolveOidcToken(
    String accountCacheKey, {
    TokenOIDC? fallbackToken,
  }) async {
    try {
      return await authOIDCRepository.getStoredTokenOIDC(accountCacheKey);
    } catch (e) {
      if (fallbackToken != null) {
        logTrace('$runtimeType::resolveOidcToken(): '
            'storage failed, using in-memory token as fallback | error=${e.runtimeType}');
        authOIDCRepository
            .persistTokenOIDCAt(accountCacheKey, fallbackToken)
            .catchError(
              (Object repairError) => logError(
                '$runtimeType::resolveOidcToken(): '
                'failed to repair token storage | error=${repairError.runtimeType}',
                exception: repairError,
              ),
            );
        return fallbackToken;
      }
      rethrow;
    }
  }
}
