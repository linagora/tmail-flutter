import 'package:model/oidc/request/oidc_request.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';

class AuthenticationOIDCRepositoryImpl extends AuthenticationOIDCRepository {
  final AuthenticationOIDCDataSource _oidcDataSource;

  AuthenticationOIDCRepositoryImpl(this._oidcDataSource);

  @override
  Future<bool> checkOIDCIsAvailable(OIDCRequest oidcRequest) {
    return _oidcDataSource.checkOIDCIsAvailable(oidcRequest);
  }
}