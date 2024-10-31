import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class SignInTwakeWorkplaceLoading extends LoadingState {}

class SignInTwakeWorkplaceSuccess extends Success {
  final TokenOIDC tokenOIDC;
  final Uri baseUri;
  final OIDCConfiguration oidcConfiguration;

  SignInTwakeWorkplaceSuccess(this.tokenOIDC, this.baseUri, this.oidcConfiguration);

  @override
  List<Object> get props => [tokenOIDC, baseUri, oidcConfiguration];
}

class SignInTwakeWorkplaceFailure extends FeatureFailure {
  SignInTwakeWorkplaceFailure(dynamic exception) : super(exception: exception);
}