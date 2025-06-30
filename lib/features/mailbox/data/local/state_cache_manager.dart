import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';

class StateCacheManager extends CacheManagerInteraction {

  final StateCacheClient _stateCacheClient;

  StateCacheManager(this._stateCacheClient);

  Future<State?> getState(AccountId accountId, UserName userName, StateType stateType) async {
    final stateKey = TupleKey(stateType.name, accountId.asString, userName.value).encodeKey;
    final stateCache = await _stateCacheClient.getItem(stateKey);
    return stateCache?.toState();
  }

  Future<void> saveState(AccountId accountId, UserName userName, StateCache stateCache) async {
    final stateKey = TupleKey(stateCache.type.name, accountId.asString, userName.value).encodeKey;
    return await _stateCacheClient.insertItem(stateKey, stateCache);
  }

  Future<void> deleteState(AccountId accountId, UserName userName, StateType stateType) async {
    final stateKey = TupleKey(stateType.name, accountId.asString, userName.value).encodeKey;
    return await _stateCacheClient.deleteItem(stateKey);
  }

  Future<void> deleteByKey(String key) => _stateCacheClient.deleteItem(key);

  Future<void> clear() => _stateCacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {}
}