import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

extension PersonalAccountExtension on PersonalAccount {
  AccountCache toCache() {
    return AccountCache(
      id,
      authenticationType.name,
      isSelected: isSelected,
      accountId: accountId?.id.value,
      apiUrl: apiUrl,
      userName: userName?.value);
  }

  bool get existAccountIdAndUserName => accountId != null && userName != null;
}