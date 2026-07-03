import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class AuthenticateOidcOnBrowserLoading extends LoadingState {}

class AuthenticateOidcOnBrowserSuccess extends UIState {}

class AuthenticateOidcOnBrowserFailure extends FeatureFailure {

  /// Whether SSO was confirmed by webFinger for the attempted config. When
  /// `false` the provider was only guessed from the base URL, so basic auth
  /// stays a valid fallback.
  final bool ssoConfirmed;

  AuthenticateOidcOnBrowserFailure(
    dynamic exception, {
    this.ssoConfirmed = false,
  }) : super(exception: exception);
}