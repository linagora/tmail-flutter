import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

abstract class ComposerDataSource {
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress);
}