
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';

extension PersonalAccountExtension on PersonalAccount {

  PersonalAccount fromAccount({
    required AccountId accountId,
    required String apiUrl,
    required UserName userName,
  }) {
    return PersonalAccount(
      id,
      authenticationType,
      isSelected: isSelected,
      accountId: accountId,
      apiUrl: apiUrl,
      userName: userName);
  }
}