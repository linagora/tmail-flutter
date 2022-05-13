
import 'package:contact/contact_module.dart' as contact;
import 'package:jmap_dart_client/jmap/core/session/session.dart';

extension SessionExtension on Session {

  bool get hasSupportAutoComplete =>
      capabilities.containsKey(contact.capabilityContact);
}