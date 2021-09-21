
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

abstract class Contact with EquatableMixin {
  final String displayName;
  final String email;

  Contact(this.displayName, this.email);

  @override
  List<Object> get props => [displayName, email];
}

extension ContactExtension on Contact {
  EmailAddress toEmailAddress() => EmailAddress(displayName, email);
}