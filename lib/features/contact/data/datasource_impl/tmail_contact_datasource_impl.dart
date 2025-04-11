
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/contact/data/datasource/auto_complete_datasource.dart';
import 'package:tmail_ui_user/features/contact/data/network/contact_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class TMailContactDataSourceImpl extends AutoCompleteDataSource {

  final ContactAPI _contactAPI;
  final ExceptionThrower _exceptionThrower;

  TMailContactDataSourceImpl(this._contactAPI, this._exceptionThrower);

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) {
    return Future.sync(() async {
      final listContacts = await _contactAPI.getAutoComplete(autoCompletePattern);
      return listContacts.map((contact) => contact.toEmailAddress()).toList();
    }).catchError(_exceptionThrower.throwException);
  }
}