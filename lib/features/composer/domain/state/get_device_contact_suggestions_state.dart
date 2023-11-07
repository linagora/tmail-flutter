import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class GetDeviceContactSuggestionsSuccess extends UIState {
  final List<EmailAddress> listEmailAddress;

  GetDeviceContactSuggestionsSuccess(this.listEmailAddress);

  @override
  List<Object> get props => [listEmailAddress];
}

class GetDeviceContactSuggestionsFailure extends FeatureFailure {

  GetDeviceContactSuggestionsFailure(dynamic exception) : super(exception: exception);
}