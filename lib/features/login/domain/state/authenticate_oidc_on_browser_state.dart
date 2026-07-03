import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class AuthenticateOidcOnBrowserLoading extends LoadingState {}

class AuthenticateOidcOnBrowserSuccess extends UIState {}

class AuthenticateOidcOnBrowserFailure extends FeatureFailure {

  /// Mirrors the attempted config's `OIDCConfiguration.ssoConfirmed`.
  final bool ssoConfirmed;

  AuthenticateOidcOnBrowserFailure(
    dynamic exception, {
    this.ssoConfirmed = false,
  }) : super(exception: exception);
}