
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class TMailContactDataSourceImpl extends AutoCompleteDataSource {

  final ContactAPI _contactAPI;

  TMailContactDataSourceImpl(this._contactAPI);

  @override
  Future<List<TMailContact>> getAutoComplete(AccountId accountId, String word, {int? limit}) {
    return Future.sync(() async {
      return _contactAPI.getAutoComplete(accountId, word, limit: limit);
    }).catchError((error) {
      throw error;
    });
  }
}