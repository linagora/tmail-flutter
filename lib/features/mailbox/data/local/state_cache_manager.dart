import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';

class StateCacheManager {

  final StateCacheClient _stateCacheClient;

  StateCacheManager(this._stateCacheClient);

  Future<State?> getState(AccountId accountId, UserName userName, StateType stateType) async {
    final stateKey = TupleKey(accountId.asString, userName.value, stateType.name).encodeKey;
    final stateCache = await _stateCacheClient.getItem(stateKey);
    return stateCache?.toState();
  }

  Future<void> saveState(AccountId accountId, UserName userName, StateCache stateCache) async {
    final stateCacheExist = await _stateCacheClient.isExistTable();
    final stateKey = TupleKey(accountId.asString, userName.value, stateCache.type.name).encodeKey;
    if (stateCacheExist) {
      return await _stateCacheClient.updateItem(stateKey, stateCache);
    } else {
      return await _stateCacheClient.insertItem(stateKey, stateCache);
    }
  }
}