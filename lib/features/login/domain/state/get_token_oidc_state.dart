import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';

class GetTokenOIDCLoading extends LoadingState {}

class GetTokenOIDCSuccess extends UIState {

  final TokenOIDC tokenOIDC;
  final OIDCConfiguration configuration;
  final Uri baseUri;

  GetTokenOIDCSuccess(
    this.tokenOIDC,
    this.configuration,
    this.baseUri,
  );

  @override
  List<Object> get props => [tokenOIDC, configuration, baseUri];
}

class GetTokenOIDCFailure extends FeatureFailure {

  GetTokenOIDCFailure(dynamic exception) : super(exception: exception);
}