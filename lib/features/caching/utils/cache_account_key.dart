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
  /// The user name must be a whole part, so another username that only starts
  /// with it is left alone. The account id is the part before the last match,
  /// so an account id equal to the user name is kept (ADR-0027, ADR-0114).
  static String? accountIdOf(String decoded, String userName) {
    if (userName.isEmpty) return null;
    final parts = decoded.split('|');
    for (var index = parts.length - 1; index >= 1; index--) {
      if (parts[index] == userName && parts[index - 1].isNotEmpty) {
        return parts[index - 1];
      }
    }
    return null;
  }

  static bool belongsTo({
    required String decoded,
    required String accountId,
    required String userName,
  }) =>
      accountIdOf(decoded, userName) == accountId;
}
