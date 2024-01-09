import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/basic_auth_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

extension AccountCacheExtension on AccountCache {
  AuthenticationType toAuthenticationType() =>
    AuthenticationType.values.firstWhereOrNull((type) => type.name == authType)
      ?? AuthenticationType.none;

  PersonalAccount toAccount() {
    return PersonalAccount(
      id: id,
      authType: toAuthenticationType(),
      isSelected: isSelected,
      baseUrl: baseUrl,
      accountId: accountId != null ? AccountId(Id(accountId!)) : null,
      apiUrl: apiUrl,
      userName: userName != null ? UserName(userName!) : null,
      tokenOidc: tokenOidc?.toTokenOIDC(),
      basicAuth: basicAuth?.toBasicAuth()
    );
  }

  AccountCache unselected() {
    return AccountCache(
      id: id,
      authType: authType,
      isSelected: false,
      baseUrl: baseUrl,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName,
      tokenOidc: tokenOidc,
      basicAuth: basicAuth,
    );
  }
}