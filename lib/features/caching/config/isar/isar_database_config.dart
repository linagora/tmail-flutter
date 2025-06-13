
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:tmail_ui_user/features/caching/config/database_config.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/caching/model/isar/token_oidc_collection.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class IsarDatabaseConfig extends DatabaseConfig {

  static final IsarDatabaseConfig _instance = IsarDatabaseConfig._internal();

  factory IsarDatabaseConfig() => _instance;

  IsarDatabaseConfig._internal();

  static const List<CollectionSchema> schemas = [
    TokenOidcCollectionSchema,
  ];

  Isar? _isar;

  Future<Isar> getIsarInstance() async {
    if (_isar != null && _isar!.isOpen) return _isar!;

    await onInitializeDatabase();

    return _isar!;
  }

  @override
  Future<void> onInitializeDatabase({String? databasePath}) async {
    Directory? directory;
    if (databasePath == null) {
      directory = await path_provider.getApplicationDocumentsDirectory();
    } else {
      directory = Directory(databasePath);
    }

    _isar = await Isar.open(
      schemas,
      directory: directory.path,
      name: databaseName,
    );
  }

  @override
  Future<void> onUpgradeDatabase() async {}

  @override
  String get databaseName => CachingConstants.databaseName;

  @override
  Future<void> onCloseDatabase() async {
    await _isar?.close();
  }
}
