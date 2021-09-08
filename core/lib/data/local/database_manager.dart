
abstract class DatabaseManager<T> {
  Future<bool> insertData(T newObject);

  Future<bool> insertMultipleData(List<T> listObject);

  Future<bool> deleteData(String key);

  Future<bool> updateData(T newObject);

  Future<T?> getData(String key);

  Future<List<T>> getListData({String? word, int? limit, String? orderBy});

  Future<List<T>> getListDataWithCondition(String condition, {String? word, int? limit, String? orderBy});
}