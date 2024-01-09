import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';

class AuthenticateOidcOnBrowserLoading extends LoadingState {}

class AuthenticateOidcOnBrowserSuccess extends UIState {
  final String baseUrl;
  final OIDCConfiguration oidcConfiguration;

  AuthenticateOidcOnBrowserSuccess(this.baseUrl, this.oidcConfiguration);

  @override
  List<Object?> get props => [baseUrl, oidcConfiguration];
}

class AuthenticateOidcOnBrowserFailure extends FeatureFailure {

  AuthenticateOidcOnBrowserFailure(dynamic exception) : super(exception: exception);
}