import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/manage_account_api.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final ManageAccountAPI manageAccountAPI;

  ManageAccountDataSourceImpl(this.manageAccountAPI);

  @override
  Future<IdentitiesResponse> getAllIdentities(AccountId accountId) {
    return Future.sync(() async {
      return await manageAccountAPI.getAllIdentities(accountId);
    }).catchError((error) {
      throw error;
    });
  }
}