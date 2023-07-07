import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class GetStoredTokenOidcSuccess extends UIState {
  final Uri baseUrl;
  final TokenOIDC tokenOidc;
  final OIDCConfiguration oidcConfiguration;

  GetStoredTokenOidcSuccess(this.baseUrl, this.tokenOidc, this.oidcConfiguration);

  @override
  List<Object?> get props => [baseUrl, tokenOidc, oidcConfiguration];
}

class GetStoredTokenOidcFailure extends FeatureFailure {

  GetStoredTokenOidcFailure(dynamic exception) : super(exception: exception);
}