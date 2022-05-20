import 'package:core/core.dart';
import 'package:model/model.dart';

class GetOIDCConfigurationSuccess extends UIState {

  final OIDCConfiguration oidcConfiguration;

  GetOIDCConfigurationSuccess(this.oidcConfiguration);

  @override
  List<Object> get props => [oidcConfiguration];
}

class GetOIDCConfigurationFailure extends FeatureFailure {
  final dynamic exception;

  GetOIDCConfigurationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}