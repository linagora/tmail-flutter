import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension IdentityExtension on Identity {
  EmailAddress toEmailAddress() => EmailAddress(name, email);
}