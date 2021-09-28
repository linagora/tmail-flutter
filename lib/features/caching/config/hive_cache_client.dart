
import 'package:hive/hive.dart';

abstract class HiveCacheClient<T> {

  String get tableName;

  Future<Box<T>> openTable();

  Future<void> insertItem(String key, T newObject);

  Future<void> insertMultipleItem(Map<String, T> mapObject);

  Future<T?> getItem(String key);

  Future<List<T>> getAll();

  Future<void> updateItem(String key, T newObject);

  Future<void> updateMultipleItem(Map<String, T> mapObject);

  Future<void> deleteItem(String key);

  Future<void> deleteMultipleItem(List<String> listKey);

  Future<bool> isExistItem(String key);

  Future<bool> isExistTable();
}