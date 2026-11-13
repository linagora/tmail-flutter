import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

/// Reads the account id out of a tuple key (`objectId|accountId|userName`).
class CacheAccountKey {
  static String? tryDecode(String encoded) {
    try {
      return CacheUtils.decodeKey(encoded);
    } catch (_) {
      return null;
    }
  }

  /// The account id when [decoded] belongs to [userName], otherwise null.
  ///
  /// ADR-0027 stores `objectId|accountId|userName`. A composer key keeps that
  /// order and adds its id after the user name. Only the third part is the
  /// user, so a username in the account id is left alone (ADR-0114).
  static String? accountIdOf(String decoded, String userName) {
    if (userName.isEmpty) return null;
    final parts = decoded.split('|');
    if (parts.length < 3) return null;
    if (parts[2] != userName) return null;
    if (parts[1].isEmpty) return null;
    return parts[1];
  }

  static bool belongsTo({
    required String decoded,
    required String accountId,
    required String userName,
  }) =>
      accountIdOf(decoded, userName) == accountId;
}
