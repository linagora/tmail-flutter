import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/datasource/atuthentitcation_datasource.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  final AuthenticationDataSource loginDataSource;

  AuthenticationRepositoryImpl(this.loginDataSource);

  @override
  Future<User> authenticationUser(Uri baseUrl, UserName userName, Password password) {
    return Future.value(User(UserId(userName.userName), "Alice", "Alice"));
  }
}