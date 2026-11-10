import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

final delegationCapability =
    CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:delegation'));

extension SessionDelegationExtension on Session {
  bool isDelegatedAccount(AccountId accountId) =>
      accounts[accountId]?.isPersonal == false;

  bool get supportsDelegation => capabilities.containsKey(delegationCapability);

  /// Owner mailboxes listed on this session (`isPersonal: false`).
  Iterable<MapEntry<AccountId, Account>> get delegatedAccounts =>
      accounts.entries.where((entry) => entry.value.isPersonal == false);

  bool get hasDelegatedAccounts => delegatedAccounts.isNotEmpty;
}
