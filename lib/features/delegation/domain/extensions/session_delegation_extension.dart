import 'package:delegation/utils/delegation_constants.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';

extension SessionDelegationExtension on Session {
  /// An owner mailbox I can open: `isPersonal: false` with `jmap:mail`.
  bool isDelegatedAccount(AccountId accountId) {
    final account = accounts[accountId];
    return account != null && _isOpenableDelegatedAccount(account);
  }

  /// [accountId] while this session still lists it as delegated, otherwise my own account.
  AccountId delegatedAccountIdOrMine(AccountId? accountId) =>
      accountId != null && isDelegatedAccount(accountId) ? accountId : this.accountId;

  bool get supportsDelegation => capabilities.containsKey(DelegationConstants.delegationCapability);

  /// Owner mailboxes on this session that [isDelegatedAccount] accepts.
  Iterable<MapEntry<AccountId, Account>> get delegatedAccounts =>
      accounts.entries.where((entry) => _isOpenableDelegatedAccount(entry.value));

  bool get hasDelegatedAccounts => delegatedAccounts.isNotEmpty;

  static bool _isOpenableDelegatedAccount(Account account) =>
      account.isPersonal == false &&
      account.accountCapabilities.containsKey(CapabilityIdentifier.jmapMail);
}
