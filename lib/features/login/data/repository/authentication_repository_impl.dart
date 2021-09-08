import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final AuthenticationDataSource loginDataSource;

  AuthenticationRepositoryImpl(this.loginDataSource);

  @override
  Future<UserProfile> authenticationUser(Uri baseUrl, UserName userName, Password password) {
    return loginDataSource.authenticationUser(baseUrl, userName, password);
  }
}