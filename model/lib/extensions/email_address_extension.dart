import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension EmailAddressExtension on EmailAddress {

  String asString() {
    if (name != null && name!.isNotEmpty) {
      return name!;
    } else if (email != null && email!.isNotEmpty) {
      return email!;
    }
    return '';
  }
}