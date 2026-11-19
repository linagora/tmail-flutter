import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';

/// The delegated account the Android and iOS app shows at its next start, per signed-in username (ADR-0114).
/// No entry means `mine`.
abstract class LastShownAccountStore {
  AccountId? read(UserName username);

  Future<void> save(UserName username, AccountId accountId);

  Future<void> remove(UserName username);
}
