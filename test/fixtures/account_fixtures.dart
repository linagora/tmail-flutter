import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';

class AccountFixtures {
  static final aliceAccountId = AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));
  static final aliceAccount = PersonalAccount(
    id: 'dab',
    authenticationType: AuthenticationType.oidc,
    isSelected: true,
    accountId: aliceAccountId,
    baseUrl: 'https://domain.com/jmap',
    apiUrl: 'https://domain.com/jmap',
    userName: UserName('Alice')
  );
}