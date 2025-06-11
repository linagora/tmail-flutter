import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/model/isar/token_oidc_collection.dart';

extension TokenOidcCollectionExtension on TokenOidcCollection {
  TokenOIDC toTokenOidc() {
    return TokenOIDC(
      token,
      TokenId(tokenId),
      refreshToken,
      expiredTime: expiredTime,
    );
  }
}
