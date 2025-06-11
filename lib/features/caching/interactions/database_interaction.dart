import 'package:isar/isar.dart';

abstract class DatabaseInteraction<T> {
  Future<Isar> get isar;

  Future<void> insertItem(T newObject);

  Future<void> deleteItem(String key);

  Future<T> getItem(String key);

  Future<List<T>> getAll();

  Future<void> clear();
}
