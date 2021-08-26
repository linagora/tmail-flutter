import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension EmailAddressExtension on EmailAddress {

  String asString() {
    if (getName().isNotEmpty) {
      return name!;
    } else if (getEmail().isNotEmpty) {
      return email!;
    }
    return '';
  }

  String asFullString() {
    if (getName().isNotEmpty) {
      if (getEmail().isNotEmpty) {
        return '${name!} <${email!}>';
      }
      return name!;
    } else if (getEmail().isNotEmpty) {
      return email!;
    }
    return '';
  }

  String getEmail() => email != null ? email! : '';

  String getName() => name != null ? name! : '';
}