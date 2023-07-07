import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/token_oidc.dart';

class RefreshTokenOIDCSuccess extends UIState {

  final TokenOIDC tokenOIDC;

  RefreshTokenOIDCSuccess(this.tokenOIDC);

  @override
  List<Object> get props => [tokenOIDC];
}

class RefreshTokenOIDCFailure extends FeatureFailure {

  RefreshTokenOIDCFailure(dynamic exception) : super(exception: exception);
}