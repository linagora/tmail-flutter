import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/sign_in_email_link.dart';

void main() {
  group('SignInEmailLink.tryParse', () {
    test('WHEN the link opens a dashboard account THEN the dashboard starts on its parameters', () {
      final link = SignInEmailLink.tryParse('/dashboard?account=owner-account&type=normal');

      expect(link?.opensSettings, isFalse);
      expect(link?.dashboardParameters, {'account': 'owner-account', 'type': 'normal'});
    });

    test('WHEN the link opens Settings › Delegation THEN it opens Settings and no dashboard parameters', () {
      final link = SignInEmailLink.tryParse('/settings?type=delegation');

      expect(link?.opensSettings, isTrue);
      expect(link?.dashboardParameters, isNull);
    });

    for (final notEmailLink in <String?>[
      null,
      '',
      '/dashboard',
      '/dashboard?account=',
      '/dashboard?type=normal',
      '/dashboard/emails?account=owner-account',
      '/settings',
      '/settings?type=profiles',
      '/login?account=owner-account',
      'https://evil.example/dashboard?account=owner-account',
      '//evil.example/dashboard?account=owner-account',
      'javascript:alert(1)',
      '/dashboard?account=%E0%A4%A',
    ]) {
      test('SHOULD NOT accept "$notEmailLink"', () {
        expect(SignInEmailLink.tryParse(notEmailLink), isNull);
      });
    }
  });

  group('keepSignInEmailLink and takeSignInEmailLink', () {
    late SessionStorageManager storage;

    setUp(() {
      PlatformInfo.isTestingForWeb = true;
      storage = Get.put(SessionStorageManager());
      storage.remove(SignInEmailLink.storageKey);
    });

    tearDown(() {
      storage.remove(SignInEmailLink.storageKey);
      PlatformInfo.isTestingForWeb = false;
      Get.reset();
    });

    test('WHEN a signed-out page is an email link THEN it is taken once after sign-in', () {
      keepSignInEmailLink('/dashboard?account=owner-account', {'account': 'owner-account'});

      expect(hasSignInEmailLink(), isTrue);
      expect(hasSignInEmailLink(), isTrue, reason: 'has does not consume the link');
      expect(takeSignInEmailLink()?.dashboardParameters, {'account': 'owner-account'});
      expect(takeSignInEmailLink(), isNull);
      expect(hasSignInEmailLink(), isFalse);
    });

    test('WHEN the settings link is kept THEN the stored link drops null parameters', () {
      keepSignInEmailLink('/settings', {'type': 'delegation', 'context': null});

      expect(takeSignInEmailLink()?.uri.toString(), '/settings?type=delegation');
    });

    test('SHOULD NOT replace a kept link WHEN the next signed-out page is not an email link', () {
      keepSignInEmailLink('/settings', {'type': 'delegation'});

      keepSignInEmailLink('/login', {});
      keepSignInEmailLink('/dashboard', {'type': 'normal'});

      expect(takeSignInEmailLink()?.opensSettings, isTrue);
    });

    test('SHOULD NOT open a tampered stored value AND removes it', () {
      storage.save(SignInEmailLink.storageKey, 'https://evil.example/dashboard?account=owner-account');

      expect(hasSignInEmailLink(), isFalse);
      expect(takeSignInEmailLink(), isNull);
      expect(storage.sessionStorage.containsKey(SignInEmailLink.storageKey), isFalse);
    });

    test('SHOULD NOT throw on a malformed stored value AND removes it', () {
      storage.save(SignInEmailLink.storageKey, '/dashboard?account=%E0%A4%A');

      expect(hasSignInEmailLink(), isFalse);
      expect(takeSignInEmailLink(), isNull);
      expect(storage.sessionStorage.containsKey(SignInEmailLink.storageKey), isFalse);
    });

    test('SHOULD NOT keep or take a link on mobile', () {
      PlatformInfo.isTestingForWeb = false;

      keepSignInEmailLink('/dashboard', {'account': 'owner-account'});

      expect(storage.sessionStorage.containsKey(SignInEmailLink.storageKey), isFalse);
      storage.save(SignInEmailLink.storageKey, '/dashboard?account=owner-account');
      expect(takeSignInEmailLink(), isNull);
    });
  });
}
