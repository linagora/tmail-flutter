import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension UsernameExtension on UserName {
  String get firstCharacter => value.isNotEmpty ? value[0].toUpperCase() : '';

  EmailAddress toEmailAddress() => EmailAddress(null, value);
}