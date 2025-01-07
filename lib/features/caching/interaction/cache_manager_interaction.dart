
abstract class CacheManagerInteraction {
  const CacheManagerInteraction();

  Future<void> migrateHiveToIsolatedHive();
}