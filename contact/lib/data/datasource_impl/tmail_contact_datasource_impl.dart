
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:contact/data/network/contact_api.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';

class TMailContactDataSourceImpl extends AutoCompleteDataSource {

  final ContactAPI _contactAPI;

  TMailContactDataSourceImpl(this._contactAPI);

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) {
    return Future.sync(() async {
      final listContacts = await _contactAPI.getAutoComplete(autoCompletePattern);
      return listContacts.map((contact) => contact.toEmailAddress()).toList();
    }).catchError((error) {
      throw error;
    });
  }
}