import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class GetAutoCompleteSuccess extends UIState {

  final List<EmailAddress> listEmailAddress;

  GetAutoCompleteSuccess(this.listEmailAddress);

  @override
  List<Object?> get props => [listEmailAddress];
}

class GetAutoCompleteFailure extends FeatureFailure {

  GetAutoCompleteFailure(dynamic exception) : super(exception: exception);
}