
abstract class DatabaseConfig {

  String get databaseName;

  Future<void> onInitializeDatabase({String? databasePath});

  Future<void> onUpgradeDatabase();

  Future<void> onCloseDatabase();
}