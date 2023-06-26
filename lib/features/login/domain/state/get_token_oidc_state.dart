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

  GetTokenOIDCFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}