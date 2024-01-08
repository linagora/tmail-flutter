import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/basic_auth_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension PersonalAccountExtension on PersonalAccount {
  AccountCache toCache({bool? isSelected}) {
    return AccountCache(
      id: id,
      authType: authType.name,
      isSelected: isSelected ?? this.isSelected,
      baseUrl: baseUrl,
      accountId: accountId?.id.value,
      apiUrl: apiUrl,
      userName: userName?.value,
      tokenOidc: tokenOidc?.toTokenOidcCache(),
      basicAuth: basicAuth?.toBasicAuthCache(),
    );
  }

  PersonalAccount updateToken(TokenOIDC newTokenOIDC) {
    return PersonalAccount(
      id: newTokenOIDC.tokenIdHash,
      authType: authType,
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName,
      tokenOidc: newTokenOIDC,
      basicAuth: basicAuth
    );
  }

  PersonalAccount addAccountId({
    required AccountId accountId,
    required String apiUrl,
    required UserName userName,
  }) {
    return PersonalAccount(
      id: id,
      authType: authType,
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName,
      tokenOidc: tokenOidc,
      basicAuth: basicAuth
    );
  }

  String? get authenticationHeader => authType == AuthenticationType.oidc
    ? tokenOidc?.authenticationHeader
    : basicAuth?.authenticationHeader;
}