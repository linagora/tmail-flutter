import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class SignInSaasLoading extends LoadingState {}

class SignInSaasSuccess extends Success {
  final TokenOIDC tokenOIDC;
  final Uri baseUri;
  final OIDCConfiguration oidcConfiguration;

  SignInSaasSuccess(this.tokenOIDC, this.baseUri, this.oidcConfiguration);

  @override
  List<Object> get props => [tokenOIDC, baseUri, oidcConfiguration];
}

class SignInSaasFailure extends FeatureFailure {
  SignInSaasFailure(dynamic exception) : super(exception: exception);
}