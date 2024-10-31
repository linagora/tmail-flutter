import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class SignUpTwakeWorkplaceLoading extends LoadingState {}

class SignUpTwakeWorkplaceSuccess extends Success {
  final TokenOIDC tokenOIDC;
  final Uri baseUri;
  final OIDCConfiguration oidcConfiguration;

  SignUpTwakeWorkplaceSuccess(this.tokenOIDC, this.baseUri, this.oidcConfiguration);

  @override
  List<Object> get props => [tokenOIDC, baseUri, oidcConfiguration];
}

class SignUpTwakeWorkplaceFailure extends FeatureFailure {
  SignUpTwakeWorkplaceFailure(dynamic exception) : super(exception: exception);
}