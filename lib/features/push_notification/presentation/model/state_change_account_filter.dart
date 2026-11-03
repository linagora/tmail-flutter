import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';

/// Which accounts of a [StateChange] the push layer may handle (ADR-0114 Sync).
///
/// T-03 drops delegated accounts. T-06 / T-09 turn [includeDelegated] on when
/// `delegationEnabledProvider` is true and the session still lists them.
class StateChangeAccountFilter {
  final AccountId personalAccountId;
  final AccountId? activeAccountId;
  final bool isSwitching;
  final Set<AccountId> delegatedAccountIds;
  final bool includeDelegated;

  const StateChangeAccountFilter({
    required this.personalAccountId,
    this.activeAccountId,
    this.isSwitching = false,
    this.delegatedAccountIds = const {},
    this.includeDelegated = false,
  });

  bool shouldProcess(AccountId accountId) {
    if (accountId == personalAccountId) return true;
    if (accountId == activeAccountId && !isSwitching) return true;
    if (includeDelegated && delegatedAccountIds.contains(accountId)) return true;
    return false;
  }

  bool shouldRefreshView(AccountId accountId) =>
      accountId == activeAccountId && !isSwitching;

  bool shouldKeepDelivery(AccountId accountId) =>
      accountId == personalAccountId ||
      (includeDelegated && delegatedAccountIds.contains(accountId));

  bool shouldStoreOfflineBodies(AccountId accountId) =>
      accountId == personalAccountId;

  Iterable<AccountId> accountsToProcess(StateChange stateChange) =>
      stateChange.changed.keys.where(shouldProcess);
}
