
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class AuthenticateOidcOnBrowserLoading extends LoadingState {

  AuthenticateOidcOnBrowserLoading();

  @override
  List<Object> get props => [];
}

class AuthenticateOidcOnBrowserSuccess extends UIState {

  AuthenticateOidcOnBrowserSuccess();

  @override
  List<Object> get props => [];
}

class AuthenticateOidcOnBrowserFailure extends FeatureFailure {
  final dynamic exception;

  AuthenticateOidcOnBrowserFailure(this.exception);

  @override
  List<Object> get props => [exception];
}