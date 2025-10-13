import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class AuthenticationDataSourceImpl extends AuthenticationDataSource {

  final ExceptionThrower _exceptionThrower;

  AuthenticationDataSourceImpl(this._exceptionThrower);

  @override
  Future<UserName> authenticationUser(Uri baseUrl, UserName userName, Password password) async {
    return Future.sync(() async {
      return userName;
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}