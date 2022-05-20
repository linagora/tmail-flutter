import 'package:core/core.dart';

class CheckOIDCIsAvailableSuccess extends UIState {

  CheckOIDCIsAvailableSuccess();

  @override
  List<Object> get props => [];
}

class CheckOIDCIsAvailableFailure extends FeatureFailure {
  final dynamic exception;

  CheckOIDCIsAvailableFailure(this.exception);

  @override
  List<Object> get props => [exception];
}