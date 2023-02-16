
abstract class CacheVersionClient {

  String get versionKey;

  Future<bool> storeVersion(int newVersion);

  Future<int?> getLatestVersion();
}