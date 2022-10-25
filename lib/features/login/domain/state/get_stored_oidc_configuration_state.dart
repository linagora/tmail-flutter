import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';

class GetStoredOidcConfigurationLoading extends LoadingState {

  GetStoredOidcConfigurationLoading();

  @override
  List<Object?> get props => [];
}

class GetStoredOidcConfigurationSuccess extends UIState {
  final OIDCConfiguration oidcConfiguration;

  GetStoredOidcConfigurationSuccess(this.oidcConfiguration);

  @override
  List<Object?> get props => [oidcConfiguration];
}

class GetStoredOidcConfigurationFailure extends FeatureFailure {
  final dynamic exception;

  GetStoredOidcConfigurationFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}