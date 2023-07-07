import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/contact/contact.dart';

class GetDeviceContactSuggestionsSuccess extends UIState {
  final List<Contact> results;

  GetDeviceContactSuggestionsSuccess(this.results);

  @override
  List<Object> get props => [results];
}

class GetDeviceContactSuggestionsFailure extends FeatureFailure {

  GetDeviceContactSuggestionsFailure(dynamic exception) : super(exception: exception);
}