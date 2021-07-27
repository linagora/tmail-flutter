import 'package:model/model.dart';

abstract class CredentialRepository {
  Future saveBaseUrl(Uri baseUrl);

  Future removeBaseUrl();

  Future<Uri> getBaseUrl();

  Future saveUserName(UserName userName);

  Future removeUserName();

  Future<UserName> getUserName();

  Future savePassword(Password password);

  Future removePassword();

  Future<Password> getPassword();
}