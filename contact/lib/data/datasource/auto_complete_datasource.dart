
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

abstract class AutoCompleteDataSource {
  Future<List<TMailContact>> getAutoComplete(AccountId accountId, String word, {int? limit});
}