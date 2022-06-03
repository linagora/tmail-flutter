
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class LogoutOidcSuccess extends UIState {

  LogoutOidcSuccess();

  @override
  List<Object> get props => [];
}

class LogoutOidcFailure extends FeatureFailure {
  final dynamic exception;

  LogoutOidcFailure(this.exception);

  @override
  List<Object> get props => [exception];
}