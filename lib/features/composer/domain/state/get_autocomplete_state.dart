import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class GetAutoCompleteSuccess extends UIState {

  final List<EmailAddress> listEmailAddress;

  GetAutoCompleteSuccess(this.listEmailAddress);

  @override
  List<Object?> get props => [listEmailAddress];
}

class GetAutoCompleteFailure extends FeatureFailure {
  final dynamic exception;

  GetAutoCompleteFailure(this.exception);

  @override
  List<Object> get props => [exception];
}