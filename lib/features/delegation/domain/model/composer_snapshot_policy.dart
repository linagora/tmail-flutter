import 'package:jmap_dart_client/jmap/account_id.dart';

/// Composer snapshots of a delegated account (ADR-0114 local data).
class ComposerSnapshotPolicy {
  /// Restore the snapshot of the account that is shown, and no other.
  /// Drafts of the personal account restore as today, because it is shown.
  static bool mayRestore({
    required AccountId snapshotAccountId,
    required AccountId shownAccountId,
  }) =>
      snapshotAccountId == shownAccountId;

  /// Logout removes delegated snapshots of this user and leaves the personal ones.
  static bool removeOnLogout({
    required AccountId snapshotAccountId,
    required AccountId personalAccountId,
    required String snapshotUserName,
    required String signedInUserName,
  }) =>
      snapshotUserName == signedInUserName &&
      snapshotAccountId != personalAccountId;
}
