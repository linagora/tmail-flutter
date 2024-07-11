import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/basic_auth_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension PersonalAccountExtension on PersonalAccount {
  AccountCache toCache() {
    return AccountCache(
      id: id,
      authenticationType: authenticationType.name,
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId?.asString,
      apiUrl: apiUrl,
      userName: userName?.value,
      tokenOidc: tokenOidc?.toTokenOidcCache(),
      basicAuth: basicAuth?.toBasicAuthCache(),
    );
  }

  PersonalAccount updateToken(TokenOIDC newTokenOIDC) {
    return PersonalAccount(
      id: newTokenOIDC.tokenIdHash,
      authenticationType: authenticationType,
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName,
      tokenOidc: newTokenOIDC,
      basicAuth: basicAuth
    );
  }

  PersonalAccount updateAccountId({
    required AccountId accountId,
    required String apiUrl,
    required UserName userName,
  }) {
    return PersonalAccount(
      id: id,
      authenticationType: authenticationType,
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName,
      tokenOidc: tokenOidc,
      basicAuth: basicAuth
    );
  }

  String? get authenticationHeader => authenticationType == AuthenticationType.oidc
    ? tokenOidc?.authenticationHeader
    : basicAuth?.authenticationHeader;
}