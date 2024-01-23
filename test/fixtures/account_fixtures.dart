import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';

class AccountFixtures {
  static final aliceAccountId = AccountId(Id('411ce'));
  static final oidcAccount = PersonalAccount(
    'dab',
    AuthenticationType.oidc,
    isSelected: true);
}