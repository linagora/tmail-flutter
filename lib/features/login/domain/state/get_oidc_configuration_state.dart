import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/oidc_configuration.dart';

class GetOIDCConfigurationLoading extends LoadingState {}

class GetOIDCConfigurationSuccess extends UIState {

  final OIDCConfiguration oidcConfiguration;

  GetOIDCConfigurationSuccess(this.oidcConfiguration);

  @override
  List<Object> get props => [oidcConfiguration];
}

class GetOIDCConfigurationFailure extends FeatureFailure {

  GetOIDCConfigurationFailure(dynamic exception) : super(exception: exception);
}

class GetOIDCConfigurationFromBaseUrlFailure extends FeatureFailure {

  GetOIDCConfigurationFromBaseUrlFailure(dynamic exception) : super(exception: exception);
}