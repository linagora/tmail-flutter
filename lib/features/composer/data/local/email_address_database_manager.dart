
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';

class EmailAddressDatabaseManager implements DatabaseManager<EmailAddress> {
  final DatabaseClient _databaseClient;

  EmailAddressDatabaseManager(this._databaseClient);

  @override
  Future<bool> deleteData(String key) async {
    final res = await _databaseClient.deleteData(EmailAddressTable.TABLE_NAME, EmailAddressTable.EMAIL, key);
    return res > 0 ? true : false;
  }

  @override
  Future<EmailAddress?> getData(String key) async {
    final res = await _databaseClient.getData(EmailAddressTable.TABLE_NAME, EmailAddressTable.EMAIL, key);
    return res.isNotEmpty ? EmailAddressCache.fromJson(res.first).toEmailAddress() : null;
  }

  @override
  Future<List<EmailAddress>> getListData({String? word, int? limit, String? orderBy}) async {
    final res = await _databaseClient.getListData(EmailAddressTable.TABLE_NAME, limit: limit ?? 10, orderBy: orderBy ?? EmailAddressTable.NAME);
    return res.isNotEmpty
      ? res.map((mapObject) => EmailAddressCache.fromJson(mapObject).toEmailAddress()).toList()
      : [];
  }

  @override
  Future<bool> insertData(EmailAddress emailAddress) async {
    final res = await _databaseClient.insertData(EmailAddressTable.TABLE_NAME, emailAddress.toEmailAddressCache().toJson());
    return res > 0 ? true : false;
  }

  @override
  Future<bool> updateData(EmailAddress emailAddress) async {
    final res = await _databaseClient.updateData(
      EmailAddressTable.TABLE_NAME,
      EmailAddressTable.EMAIL,
      emailAddress.getEmail(),
      emailAddress.toEmailAddressCache().toJson());
    return res > 0 ? true : false;
  }

  @override
  Future<bool> insertMultipleData(List<EmailAddress> listObject) async {
    final listEmailAddressNotExist = await Future.wait(listObject
      .map((emailAddress) async {
        final emailAddressExist = await _databaseClient.getData(
            EmailAddressTable.TABLE_NAME,
            EmailAddressTable.EMAIL,
            emailAddress.email ?? '');
        return emailAddressExist.isEmpty ? emailAddress : null;})
      .toList());

    listEmailAddressNotExist.removeWhere((element) => element == null);

    final mapObjects = listEmailAddressNotExist
      .map((emailAddress) => emailAddress!.toEmailAddressCache().toJson())
      .toList();

    final res = await _databaseClient.insertMultipleData(EmailAddressTable.TABLE_NAME, mapObjects);
    return res.isNotEmpty ? true : false;
  }

  @override
  Future<List<EmailAddress>> getListDataWithCondition(String condition, {String? word, int? limit, String? orderBy}) async {
    final sqlQuery = 'SELECT * FROM ${EmailAddressTable.TABLE_NAME} '
        'WHERE $condition '
        'ORDER BY ${orderBy ?? EmailAddressTable.NAME} '
        'LIMIT ${limit ?? 10}';

    final res = await _databaseClient.getDataBySql(sqlQuery);

    return res.isNotEmpty
      ? res.map((mapObject) => EmailAddressCache.fromJson(mapObject).toEmailAddress()).toList()
      : [];
  }
}