import 'package:jmap_dart_client/jmap/account_id.dart';

/// Received mail is stored for offline reading on the personal account only.
class OfflineEmailBodyPolicy {
  static bool mayStore({
    required AccountId accountId,
    required AccountId personalAccountId,
  }) =>
      accountId == personalAccountId;
}
