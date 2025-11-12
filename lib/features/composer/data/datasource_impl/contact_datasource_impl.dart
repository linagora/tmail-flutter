
import 'package:contacts_service/contacts_service.dart' as contact_service;
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ContactDataSourceImpl extends ContactDataSource {

  final ExceptionThrower _exceptionThrower;

  ContactDataSourceImpl(this._exceptionThrower);

  @override
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern) async {
    return Future.sync(() async {
      if (autoCompletePattern.word.isEmpty) {
        return <DeviceContact>[];
      } else {
        final suggestedList = await contact_service.ContactsService
          .getContactsByEmailOrName(autoCompletePattern.word);
        if (suggestedList.isNotEmpty) {
          return suggestedList.expand((contact) => _toDeviceContact(contact)).toList();
        } else {
          return <DeviceContact>[];
        }
      }
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  List<DeviceContact> _toDeviceContact(contact_service.Contact contact) {
    if (contact.emails != null) {
      return contact.emails!
        .where((email) => email.value != null && GetUtils.isEmail(email.value!))
        .map((email) => DeviceContact(contact.displayName ?? '', email.value ?? ''))
        .toList();
    }
    return <DeviceContact>[];
  }
}