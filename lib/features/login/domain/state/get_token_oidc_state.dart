import 'package:core/core.dart';
import 'package:model/model.dart';

class GetTokenOIDCLoading extends LoadingState {

  GetTokenOIDCLoading();

  @override
  List<Object> get props => [];
}

class GetTokenOIDCSuccess extends UIState {

  final TokenOIDC tokenOIDC;
  final OIDCConfiguration configuration;

  GetTokenOIDCSuccess(this.tokenOIDC, this.configuration);

  @override
  List<Object> get props => [tokenOIDC, configuration];
}

class GetTokenOIDCFailure extends FeatureFailure {
  final dynamic exception;

  GetTokenOIDCFailure(this.exception);

  @override
  List<Object> get props => [exception];
}