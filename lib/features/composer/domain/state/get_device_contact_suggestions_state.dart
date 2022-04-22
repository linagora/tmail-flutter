
import 'package:core/core.dart';
import 'package:model/model.dart';

class GetDeviceContactSuggestionsSuccess extends UIState {
  final List<Contact> results;

  GetDeviceContactSuggestionsSuccess(this.results);

  @override
  List<Object> get props => [results];
}

class GetDeviceContactSuggestionsFailure extends FeatureFailure {
  final dynamic exception;

  GetDeviceContactSuggestionsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}