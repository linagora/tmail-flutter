import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class AutoSignInViaDeepLinkLoading extends LoadingState {}

class AutoSignInViaDeepLinkSuccess extends Success {
  final TokenOIDC tokenOIDC;
  final Uri baseUri;
  final OIDCConfiguration oidcConfiguration;

  AutoSignInViaDeepLinkSuccess(this.tokenOIDC, this.baseUri, this.oidcConfiguration);

  @override
  List<Object> get props => [tokenOIDC, baseUri, oidcConfiguration];
}

class AutoSignInViaDeepLinkFailure extends FeatureFailure {
  AutoSignInViaDeepLinkFailure(dynamic exception) : super(exception: exception);
}