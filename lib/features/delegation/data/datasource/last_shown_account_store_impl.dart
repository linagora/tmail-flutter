import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';

class LastShownAccountStoreImpl implements LastShownAccountStore {
  static const String _keyPrefix = 'delegation.last_shown_account.';

  final SharedPreferences _sharedPreferences;

  LastShownAccountStoreImpl(this._sharedPreferences);

  @override
  AccountId? read(UserName username) {
    final accountId = _sharedPreferences.getString(_keyOf(username));
    return accountId == null ? null : AccountId(Id(accountId));
  }

  @override
  Future<void> save(UserName username, AccountId accountId) =>
      _sharedPreferences.setString(_keyOf(username), accountId.id.value);

  @override
  Future<void> remove(UserName username) =>
      _sharedPreferences.remove(_keyOf(username));

  String _keyOf(UserName username) => '$_keyPrefix${username.value}';
}
