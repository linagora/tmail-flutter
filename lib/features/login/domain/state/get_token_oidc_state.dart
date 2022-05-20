import 'package:core/core.dart';
import 'package:model/model.dart';

class GetTokenOIDCSuccess extends UIState {

  final TokenOIDC tokenOIDC;

  GetTokenOIDCSuccess(this.tokenOIDC);

  @override
  List<Object> get props => [tokenOIDC];
}

class GetTokenOIDCFailure extends FeatureFailure {
  final dynamic exception;

  GetTokenOIDCFailure(this.exception);

  @override
  List<Object> get props => [exception];
}