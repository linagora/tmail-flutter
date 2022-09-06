import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

abstract class CredentialRepository {
  Future saveBaseUrl(Uri baseUrl);

  Future removeBaseUrl();

  Future<Uri> getBaseUrl();

  Future removeUserName();

  Future<UserName> getUserName();

  Future removePassword();

  Future<Password> getPassword();

  Future saveUserProfile(UserProfile userProfile);

  Future removeUserProfile();

  Future<UserProfile> getUserProfile();

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache);
}