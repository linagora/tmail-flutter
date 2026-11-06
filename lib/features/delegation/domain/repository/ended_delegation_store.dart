import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';

abstract class EndedDelegationStore {
  /// Account ids with local data for [userName], plus delegated ids on the
  /// keychain entry of [personalAccountId]. Other usernames are omitted.
  Future<Set<AccountId>> storedAccountIds({
    required UserName userName,
    required AccountId personalAccountId,
  });

  Future<StoredDelegatedAccount> describe(UserName userName, AccountId accountId);

  Future<void> delete({
    required UserName userName,
    required AccountId personalAccountId,
    required AccountId accountId,
  });

  /// Logout removes delegated composer snapshots of this user. Personal ones stay.
  Future<void> removeDelegatedComposerSnapshots({
    required UserName userName,
    required AccountId personalAccountId,
  });
}
