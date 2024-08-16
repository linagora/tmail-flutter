import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';

abstract class IdentityCreatorDataSource {
  Future<void> saveIdentityCacheOnWeb(
    AccountId accountId,
    UserName userName,
    {required IdentityCache identityCache});
}