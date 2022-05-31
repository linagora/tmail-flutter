import 'package:model/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension AccountCacheExtension on AccountCache {
  AuthenticationType fromAuthenticationTypeString() {
    if (authenticationType == 'basic') {
      return AuthenticationType.basic;
    } else if (authenticationType == 'oidc') {
      return AuthenticationType.oidc;
    } else {
      return AuthenticationType.none;
    }
  }

  Account toAccount() {
    final authenticationType = fromAuthenticationTypeString();
    return Account(id, authenticationType, isSelected: isSelected);
  }
}