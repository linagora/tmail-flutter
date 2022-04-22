
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_cache_extension.dart';

class StateDataSourceImpl extends StateDataSource {

  final StateCacheClient _stateCacheClient;

  StateDataSourceImpl(this._stateCacheClient);

  @override
  Future<State?> getState(StateType stateType) {
    return Future.sync(() async {
      final stateCache = await _stateCacheClient.getItem(stateType.value);
      return stateCache?.toState();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> saveState(StateCache stateCache) {
    return Future.sync(() async {
      final stateCacheExist = await _stateCacheClient.isExistTable();
      if (stateCacheExist) {
        return await _stateCacheClient.updateItem(stateCache.type.value, stateCache);
      } else {
        return await _stateCacheClient.insertItem(stateCache.type.value, stateCache);
      }
    }).catchError((error) {
      throw error;
    });
  }
}