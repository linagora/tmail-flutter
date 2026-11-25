import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

/// The delegated accounts of [session] whose pushes are kept, none while delegation is off.
Set<AccountId> notifiedDelegatedAccountIds(Session? session, PreferencesSetting settings) =>
    isDelegationEnabled(session, settings)
        ? session!.delegatedAccounts.map((entry) => entry.key).toSet()
        : const {};

/// Which accounts of a [StateChange] the push layer may handle (ADR-0114 Sync).
///
/// Delegated accounts are dropped unless [includeDelegated] is on and
/// [delegatedAccountIds] lists them (see [notifiedDelegatedAccountIds]).
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
