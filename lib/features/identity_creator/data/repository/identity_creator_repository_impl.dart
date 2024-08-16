import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource/identity_creator_data_source.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/repository/identity_creator_repository.dart';

class IdentityCreatorRepositoryImpl implements IdentityCreatorRepository {
  IdentityCreatorRepositoryImpl(this._identityCreatorDataSource);

  final IdentityCreatorDataSource _identityCreatorDataSource;

  @override
  Future<void> saveIdentityCacheOnWeb(
    AccountId accountId,
    UserName userName,
    {required IdentityCache identityCache}
  ) => _identityCreatorDataSource.saveIdentityCacheOnWeb(
    accountId,
    userName,
    identityCache: identityCache);
}