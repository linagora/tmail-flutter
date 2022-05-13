
import 'package:contacts_service/contacts_service.dart' as contact_service;
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';

class ContactDataSourceImpl extends ContactDataSource {

  @override
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern) async {
    if (autoCompletePattern.word.isEmpty) {
      return <DeviceContact>[];
    } else {
      final suggestedList = await contact_service.ContactsService
          .getContactsByEmailOrName(autoCompletePattern.word);
      if (suggestedList.isNotEmpty) {
        return suggestedList.expand((contact) => _toDeviceContact(contact)).toList();
      }
      return <DeviceContact>[];
    }
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