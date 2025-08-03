import 'package:core/utils/mail/mail_address.dart';
import 'package:core/utils/mail/named_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mail_address_extension.dart';

extension NamedAddressExtension on NamedAddress {
  bool get isValid => name.isNotEmpty && address.isNotEmpty;

  String get normalizedAddress => address.toLowerCase();

  EmailAddress toEmailAddress() => EmailAddress(name, address);

  EmailAddress validateToEmailAddress() {
    try {
      if (isValid) {
        return toEmailAddress();
      } else {
        final mailAddress = MailAddress.validateAddress(address);
        return mailAddress.asEmailAddress();
      }
    } catch (_) {
      return toEmailAddress();
    }
  }
}