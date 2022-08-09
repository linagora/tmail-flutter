import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class SuggestionEmailAddress with EquatableMixin {
  final EmailAddress emailAddress;
  final SuggestionEmailState state;

  SuggestionEmailAddress(this.emailAddress, {this.state = SuggestionEmailState.valid});

  @override
  List<Object?> get props => [emailAddress, state];
}

enum SuggestionEmailState {
  valid,
  duplicated,
}