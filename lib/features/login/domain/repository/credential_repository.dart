import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

abstract class CredentialRepository {
  Future saveBaseUrl(Uri baseUrl);

  Future removeBaseUrl();

  Future<Uri> getBaseUrl();

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache);

  Future<AuthenticationInfoCache?> getAuthenticationInfoStored();

  Future<void> removeAuthenticationInfo();
}