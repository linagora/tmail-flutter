import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:core/core.dart';

extension MailAddressExtension on MailAddress {
  String? get getDisplayName {
    String? localPartDetails = getLocalPartDetails();
    if(localPartDetails == null) {
      return null;
    } else {
      return '${getLocalPartWithoutDetails()} [${getLocalPartDetails()}]';
    }
  }

  EmailAddress asEmailAddress() {
    return EmailAddress(getDisplayName, asEncodedString());
  }
}