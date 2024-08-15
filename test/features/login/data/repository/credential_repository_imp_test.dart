import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';

import 'credential_repository_imp_test.mocks.dart';

@GenerateMocks([AuthenticationInfoCacheManager])
void main() {
  late SharedPreferences sharedPreferences;
  late AuthenticationInfoCacheManager authenticationInfoCacheManager;
  late CredentialRepositoryImpl credentialRepositoryImpl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    authenticationInfoCacheManager = MockAuthenticationInfoCacheManager();
    credentialRepositoryImpl = CredentialRepositoryImpl(sharedPreferences, authenticationInfoCacheManager);
  });

  group('test saveBaseUrl', () {
    test('baseUrl should be save exactly when url has no sub path', () async {
      final url = Uri.parse('https://example.com');
      credentialRepositoryImpl.saveBaseUrl(url);

      final storedUrl = await credentialRepositoryImpl.getBaseUrl();
      expect(storedUrl, url);
    });

    test('baseUrl should be save exactly when url has sub path', () async {
      final url = Uri.parse('https://example.com/basicauth');
      credentialRepositoryImpl.saveBaseUrl(url);

      final storedUrl = await credentialRepositoryImpl.getBaseUrl();
      expect(storedUrl, url);
    });

    test('baseUrl should be save exactly when url has sub port', () async {
      final url = Uri.parse('https://example.com:8080/');
      credentialRepositoryImpl.saveBaseUrl(url);

      final storedUrl = await credentialRepositoryImpl.getBaseUrl();
      expect(storedUrl, url);
    });

    test('baseUrl should be save exactly when url has port and sub path', () async {
      final url = Uri.parse('https://example.com:8080/basicauth');
      credentialRepositoryImpl.saveBaseUrl(url);

      final storedUrl = await credentialRepositoryImpl.getBaseUrl();
      expect(storedUrl, url);
    });

    test('baseUrl should be save exactly when url has multiple sub paths', () async {
      final url = Uri.parse('https://example.com:8080/basicauth/jmap');
      credentialRepositoryImpl.saveBaseUrl(url);

      final storedUrl = await credentialRepositoryImpl.getBaseUrl();
      expect(storedUrl, url);
    });
  });
}