
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class StateDataSourceImpl extends StateDataSource {

  final StateCacheManager _stateCacheManager;
  final IOSSharingManager _iosSharingManager;
  final ExceptionThrower _exceptionThrower;

  StateDataSourceImpl(
    this._stateCacheManager,
    this._iosSharingManager,
    this._exceptionThrower
  );

  @override
  Future<State?> getState(AccountId accountId, UserName userName, StateType stateType) {
    return Future.sync(() async {
      return await _stateCacheManager.getState(accountId, userName, stateType);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> saveState(AccountId accountId, UserName userName, StateCache stateCache) {
    return Future.sync(() async {
      await _stateCacheManager.saveState(accountId, userName, stateCache);
      if (PlatformInfo.isIOS && stateCache.type == StateType.email) {
        final emailDeliveryStateKeychain = await _iosSharingManager.getEmailDeliveryStateFromKeychain(accountId);
        if (emailDeliveryStateKeychain == null || emailDeliveryStateKeychain.isEmpty) {
          await _iosSharingManager.updateEmailStateInKeyChain(accountId, stateCache.state);
        }
      }
      return Future.value(null);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}