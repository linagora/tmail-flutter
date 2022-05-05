import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

abstract class ManageAccountRepository {
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId);

  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId);
}