import 'package:isar/isar.dart';
import 'package:tmail_ui_user/features/caching/config/isar/isar_database_config.dart';
import 'package:tmail_ui_user/features/caching/interactions/database_interaction.dart';
import 'package:tmail_ui_user/features/caching/model/isar/token_oidc_collection.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class IsarTokenOidcCollectionInteraction
    extends DatabaseInteraction<TokenOidcCollection> {

  @override
  Future<Isar> get isar => IsarDatabaseConfig().getIsarInstance();

  @override
  Future<void> insertItem(TokenOidcCollection newObject) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.tokenOidcCollections.put(newObject);
    });
  }

  @override
  Future<void> deleteItem(String key) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.tokenOidcCollections.delete(int.parse(key));
    });
  }

  @override
  Future<List<TokenOidcCollection>> getAll() async {
    final db = await isar;
    return await db.tokenOidcCollections.where().findAll();
  }

  @override
  Future<TokenOidcCollection> getItem(String key) async {
    final db = await isar;
    final item = await db.tokenOidcCollections.get(int.parse(key));
    if (item == null) {
      throw NotFoundStoredTokenException();
    }
    return item;
  }

  @override
  Future<void> clear() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.tokenOidcCollections.clear();
    });
  }
}
