import 'package:core/utils/mail/mail_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mail_address_extension.dart';

extension ListAddressExtension on List<String> {
  List<EmailAddress> toFilteredEmailAddressList(
    List<EmailAddress> existingEmails,
  ) {
    final existingEmailSet = existingEmails.toNormalizedEmailSet();

    final seen = <String>{};
    final result = <EmailAddress>[];

    for (final address in this) {
      final emailAddress = _validateToEmailAddress(address);
      final lowerAddress = emailAddress.emailAddress.toLowerCase();

      if (existingEmailSet.contains(lowerAddress) || !seen.add(lowerAddress)) {
        continue;
      }

      result.add(emailAddress);
    }

    return result;
  }

  EmailAddress _validateToEmailAddress(String address) {
    try {
      final mailAddress = MailAddress.validateAddress(address);
      return mailAddress.asEmailAddress();
    } catch (_) {
      return EmailAddress(null, address);
    }
  }
}
