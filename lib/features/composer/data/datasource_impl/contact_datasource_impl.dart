
import 'package:contacts_service/contacts_service.dart' as contact_service;
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';

class ContactDataSourceImpl extends ContactDataSource {

  @override
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern) async {
    final suggestedList = await contact_service.ContactsService
        .getContactsByEmailOrName(autoCompletePattern.word ?? '');
    return suggestedList.expand((contact) => _toDeviceContact(contact)).toList();
  }

  List<DeviceContact> _toDeviceContact(contact_service.Contact contact) {
    if (contact.emails != null) {
      return contact.emails!.map((email) => DeviceContact(contact.displayName ?? '', email.value ?? '')).toList();
    }
    return <DeviceContact>[];
  }
}