import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

extension SessionDelegationExtension on Session {
  bool isDelegatedAccount(AccountId accountId) =>
      accounts[accountId]?.isPersonal == false;
}
