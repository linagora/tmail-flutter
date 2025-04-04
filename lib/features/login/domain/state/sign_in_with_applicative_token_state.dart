import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class SigningInWithApplicativeToken extends LoadingState {}

class SignInWithApplicativeTokenSuccess extends UIState {
  final TokenOIDC tokenOIDC;
  final Uri baseUri;
  final OIDCConfiguration oidcConfiguration;

  SignInWithApplicativeTokenSuccess(this.tokenOIDC, this.baseUri, this.oidcConfiguration);

  @override
  List<Object> get props => [tokenOIDC, baseUri, oidcConfiguration];
}

class SignInWithApplicativeTokenFailure extends FeatureFailure {
  SignInWithApplicativeTokenFailure({super.exception});
}