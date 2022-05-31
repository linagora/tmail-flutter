import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/token_oidc.dart';

class GetStoredTokenOidcSuccess extends UIState {
  final Uri baseUrl;
  final TokenOIDC tokenOidc;

  GetStoredTokenOidcSuccess(this.baseUrl, this.tokenOidc);

  @override
  List<Object?> get props => [baseUrl, tokenOidc];
}

class GetStoredTokenOidcFailure extends FeatureFailure {
  final exception;

  GetStoredTokenOidcFailure(this.exception);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [exception];
}
