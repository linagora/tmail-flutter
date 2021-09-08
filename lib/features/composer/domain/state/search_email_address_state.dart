import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

class SearchEmailAddressSuccess extends UIState {

  final List<EmailAddress> listEmailAddress;

  SearchEmailAddressSuccess(this.listEmailAddress);

  @override
  List<Object?> get props => [listEmailAddress];
}

class SearchEmailAddressFailure extends FeatureFailure {
  final exception;

  SearchEmailAddressFailure(this.exception);

  @override
  List<Object> get props => [exception];
}