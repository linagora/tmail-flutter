import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/firebase_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/firebase_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveFirebaseDatasourceImpl extends FirebaseDatasource {

  final FirebaseCacheManager _firebaseCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveFirebaseDatasourceImpl(this._firebaseCacheManager, this._exceptionThrower);

  @override
  Future<FirebaseDto> getCurrentFirebase() {
    return Future.sync(() async {
      return await _firebaseCacheManager.getFirebase();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> setCurrentFirebase(FirebaseDto newCurrentFirebase) {
    return Future.sync(() async {
      return await _firebaseCacheManager.setFirebase(newCurrentFirebase);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> deleteCurrentFirebase(String token) {
    return Future.sync(() async {
      return await _firebaseCacheManager.deleteFirebase(token);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}