import 'package:jmap_dart_client/jmap/account_id.dart';

class StoredDelegatedAccount {
  final AccountId accountId;
  final int unsentCount;
  final int draftCount;

  const StoredDelegatedAccount({
    required this.accountId,
    required this.unsentCount,
    required this.draftCount,
  });

  int get lostCount => unsentCount + draftCount;
}

/// Which local data an online session read deletes (ADR-0114 revocation).
class EndedDelegationCleanup {
  /// A cached session waits. The personal account is never deleted, and an
  /// account the session still lists is kept. [storedAccountIds] must already
  /// be limited to the signed-in username.
  static List<AccountId> accountsToDelete({
    required bool sessionFromCache,
    required AccountId personalAccountId,
    required Set<AccountId> sessionAccountIds,
    required Set<AccountId> storedAccountIds,
  }) {
    if (sessionFromCache) return const [];
    return storedAccountIds
        .where((accountId) =>
            accountId != personalAccountId &&
            !sessionAccountIds.contains(accountId))
        .toList();
  }

  /// `null` clears the list. The same instance means nothing changed.
  static List<String>? keychainIdsAfterRemoval(
    List<String>? current,
    String removedAccountId,
  ) {
    if (current == null) return null;
    final kept = current.where((id) => id != removedAccountId).toList();
    if (kept.length == current.length) return current;
    return kept.isEmpty ? null : kept;
  }
}
