import 'dart:io';

import 'package:core/data/local/config/database_config.dart';
import 'package:core/data/local/config/email_address_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClient {

  Database? _database;
  Batch? _batch;

  Future<Database> get database async {
    return _database ?? await _initDatabase();
  }

  Future<Batch> get batch async {
    return _batch ?? (await database).batch();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, DatabaseConfig.databaseName);
    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onOpen: (db) {},
      onCreate: (db, version) async {
        final batch = db.batch();
        batch.execute(EmailAddressTable.CREATE);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {});
  }

  Future closeDatabase() async {
    final db = await database;
    _database = null;
    await db.close();
  }

  Future<int> insertData(String tableName, Map<String, dynamic> mapObject) async {
    final db = await database;
    return await db.insert(tableName, mapObject);
  }

  Future<int> deleteData(String tableName, String key, String value) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<int> updateData(String tableName, String key, String value, Map<String, dynamic> mapObject) async {
    final db = await database;
    return await db.update(
      tableName,
      mapObject,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<List<Map<String, dynamic>>> getData(String tableName, String key, String value) async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$key = ?',
      whereArgs: [value]);
  }

  Future<List<Map<String, dynamic>>> getListData(String tableName, {int? limit, String? orderBy}) async {
    final db = await database;
    return await db.query(tableName, limit: limit, orderBy: orderBy);
  }

  Future deleteLocalFile(String localPath) async {
    final fileSaved = File(localPath);
    final fileExist = await fileSaved.exists();
    if (fileExist) {
      await fileSaved.delete();
    }
  }

  Future<List<Map<String, dynamic>>> getListDataWithCondition(String tableName, String condition, List<dynamic> values, {int? limit, String? orderBy}) async {
    final db = await database;
    return await db.query(
      tableName,
      where: condition,
      whereArgs: values,
      limit: limit,
      orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> getDataBySql(String sql) async {
    final db = await database;
    return await db.rawQuery(sql);
  }

  Future<List<Object?>> insertMultipleData(String tableName, List<Map<String, dynamic>?> mapObjects) async {
    final batchInsert = await batch;
    mapObjects.forEach((element) {
      if (element != null) {
        batchInsert.insert(tableName, element);
      }
    });
    return await batchInsert.commit(noResult: false, continueOnError: true);
  }
}