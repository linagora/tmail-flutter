import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/clients/cache_version_client.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveCacheVersionClient extends CacheVersionClient {

  final SharedPreferences _sharedPreferences;
  final ExceptionThrower _exceptionThrower;

  HiveCacheVersionClient(this._sharedPreferences, this._exceptionThrower);

  @override
  String get versionKey => 'HiveCacheVersion';

  @override
  Future<int?> getLatestVersion() {
    return Future.sync(() {
      final latestVersion = _sharedPreferences.getInt(versionKey);
      return latestVersion;
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<bool> storeVersion(int newVersion) {
    return Future.sync(() async {
      return await _sharedPreferences.setInt(versionKey, newVersion);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}