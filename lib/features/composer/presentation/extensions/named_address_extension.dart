
import 'package:core/utils/mail/named_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension NamedAddressExtension on NamedAddress {
  EmailAddress toEmailAddress() => EmailAddress(name, address);
}