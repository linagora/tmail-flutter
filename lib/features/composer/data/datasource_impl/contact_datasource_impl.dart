import 'package:flutter_contacts/flutter_contacts.dart' as contact_service;
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ContactDataSourceImpl extends ContactDataSource {
  final ExceptionThrower _exceptionThrower;

  ContactDataSourceImpl(this._exceptionThrower);

  @override
  Future<List<Contact>> getContactSuggestions(
      AutoCompletePattern autoCompletePattern) async {
    return Future.sync(() async {
      if (autoCompletePattern.word.isEmpty) {
        return <DeviceContact>[];
      } else {
        final hasPermission =
            await contact_service.FlutterContacts.requestPermission();
        if (!hasPermission) return <DeviceContact>[];
        final suggestedList = await contact_service.FlutterContacts.getContacts(
            withProperties: true, withAccounts: true, withThumbnail: false);
        final filtered = suggestedList.where((c) {
          final name = c.displayName?.toLowerCase() ?? '';
          final query = autoCompletePattern.word.toLowerCase();
          final emailMatch = c.emails
              .any((e) => (e.address ?? '').toLowerCase().contains(query));
          final nameMatch = name.contains(query);
          return emailMatch || nameMatch;
        }).toList();
        if (filtered.isNotEmpty) {
          return filtered
              .expand((contact) => _toDeviceContact(contact))
              .toList();
        } else {
          return <DeviceContact>[];
        }
      }
    }).catchError(_exceptionThrower.throwException);
  }

  List<DeviceContact> _toDeviceContact(contact_service.Contact contact) {
    if (contact.emails.isNotEmpty) {
      return contact.emails
          .where((email) =>
              email.address != null && GetUtils.isEmail(email.address!))
          .map((email) =>
              DeviceContact(contact.displayName ?? '', email.address ?? ''))
          .toList();
    }
    return <DeviceContact>[];
  }
}
