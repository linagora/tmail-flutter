import 'package:core/core.dart';
import 'package:model/model.dart';

class RefreshTokenOIDCSuccess extends UIState {

  final TokenOIDC tokenOIDC;

  RefreshTokenOIDCSuccess(this.tokenOIDC);

  @override
  List<Object> get props => [tokenOIDC];
}

class RefreshTokenOIDCFailure extends FeatureFailure {
  final dynamic exception;

  RefreshTokenOIDCFailure(this.exception);

  @override
  List<Object> get props => [exception];
}