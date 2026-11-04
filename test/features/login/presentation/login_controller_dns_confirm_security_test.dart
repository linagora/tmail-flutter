import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/discovered_server_confirm_dialog.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'login_controller_test.mocks.dart';

/// Records the server shown to the user and answers when the test says so.
class _FakeDiscoveredServerConfirmDialog extends DiscoveredServerConfirmDialog {
  final List<({String emailDomain, String serverHost})> shown = [];
  Completer<bool> answer = Completer<bool>();

  @override
  Future<bool> show(
    BuildContext context, {
    required String emailDomain,
    required String serverHost,
  }) {
    shown.add((emailDomain: emailDomain, serverHost: serverHost));
    return answer.future;
  }
}

void main() {
  late MockCheckOIDCIsAvailableInteractor checkOIDCIsAvailableInteractor;
  late _FakeDiscoveredServerConfirmDialog confirmDialog;
  late LoginController loginController;

  setUp(() {
    Get.put<GetSessionInteractor>(MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(MockGetOidcUserInfoInteractor());
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authorizationInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(authorizationInterceptors, tag: BindingTag.isolateTag);
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());
    Get.testMode = true;
    dotenv.testLoad(mergeWith: {'SERVER_URL': 'https://example.com'});

    checkOIDCIsAvailableInteractor = MockCheckOIDCIsAvailableInteractor();
    when(checkOIDCIsAvailableInteractor.execute(any))
        .thenAnswer((_) => const Stream.empty());

    loginController = LoginController(
      MockAuthenticationInteractor(),
      checkOIDCIsAvailableInteractor,
      MockGetOIDCConfigurationInteractor(),
      MockGetTokenOIDCInteractor(),
      MockAuthenticateOidcOnBrowserInteractor(),
      MockGetAuthenticationInfoInteractor(),
      MockGetStoredOidcConfigurationInteractor(),
      MockSaveLoginUrlOnMobileInteractor(),
      MockGetAllRecentLoginUrlOnMobileInteractor(),
      MockSaveLoginUsernameOnMobileInteractor(),
      MockGetAllRecentLoginUsernameOnMobileInteractor(),
      MockDNSLookupToGetJmapUrlInteractor(),
      MockSignInTwakeWorkplaceInteractor(),
      MockTryGuessingWebFingerInteractor(),
      MockRemoveAuthDestinationUrlInteractor(),
    );
    confirmDialog = _FakeDiscoveredServerConfirmDialog();
    loginController.discoveredServerConfirmDialog = confirmDialog;
    loginController.loginFormType.value = LoginFormType.dnsLookupForm;
    loginController.onUsernameChange('bob@corp.example');
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    // Created inside the test zone so pump() flushes the dialog answer.
    confirmDialog.answer = Completer<bool>();
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
  }

  testWidgets(
    'SHOULD contact a server found over DNS-over-HTTPS without asking',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: true),
      );
      await tester.pump();

      expect(confirmDialog.shown, isEmpty);
      verify(checkOIDCIsAvailableInteractor.execute(any)).called(1);
    },
  );

  testWidgets(
    'SHOULD NOT contact a server found over plaintext DNS before the user confirms',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.attacker.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();

      expect(confirmDialog.shown.single.emailDomain, 'corp.example');
      expect(confirmDialog.shown.single.serverHost, 'mail.attacker.example');
      expect(loginController.urlInputController.text, isEmpty);
      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD contact the server found over plaintext DNS once the user confirms it',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();
      confirmDialog.answer.complete(true);
      await tester.pump();

      verify(checkOIDCIsAvailableInteractor.execute(any)).called(1);
      expect(loginController.loginFormType.value, LoginFormType.dnsLookupForm);
    },
  );

  testWidgets(
    'SHOULD stay on the email form without contacting the server WHEN the user declines',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.attacker.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();
      confirmDialog.answer.complete(false);
      await tester.pump();

      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
      expect(loginController.urlInputController.text, isEmpty);
      expect(loginController.loginFormType.value, LoginFormType.dnsLookupForm);
    },
  );

  testWidgets(
    'SHOULD ignore a plaintext DNS answer WHEN the user already left the email form',
    (tester) async {
      await pumpApp(tester);
      loginController.loginFormType.value = LoginFormType.baseUrlForm;

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.attacker.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();

      expect(confirmDialog.shown, isEmpty);
      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD NOT contact the server WHEN the user left the email form while the dialog was open',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();
      loginController.loginFormType.value = LoginFormType.baseUrlForm;
      confirmDialog.answer.complete(true);
      await tester.pump();

      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD ask for a server found WHEN the answer does not say how it was found',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example'),
      );
      await tester.pump();

      expect(confirmDialog.shown, hasLength(1));
      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD drop a plaintext DNS answer WHEN the email was edited after the lookup started',
    (tester) async {
      await pumpApp(tester);
      loginController.onUsernameChange('bob@other.example');

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();

      expect(confirmDialog.shown, isEmpty);
      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD NOT use the confirmed server WHEN the email was edited while the dialog was open',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();
      expect(confirmDialog.shown.single.emailDomain, 'corp.example');
      loginController.onUsernameChange('bob@other.example');
      confirmDialog.answer.complete(true);
      await tester.pump();

      verifyNever(checkOIDCIsAvailableInteractor.execute(any));
    },
  );

  testWidgets(
    'SHOULD keep a newer DNS-over-HTTPS server WHEN the user declines an older plaintext one',
    (tester) async {
      await pumpApp(tester);

      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.attacker.example', email: 'bob@corp.example', isEncryptedSource: false),
      );
      await tester.pump();
      loginController.handleSuccessViewState(
        DNSLookupToGetJmapUrlSuccess('mail.corp.example', email: 'bob@corp.example', isEncryptedSource: true),
      );
      await tester.pump();
      confirmDialog.answer.complete(false);
      await tester.pump();
      // Retrying uses the base URL still held: the newer server, not nothing.
      loginController.retryCheckOidc();
      await tester.pump();

      verify(checkOIDCIsAvailableInteractor.execute(any)).called(2);
    },
  );

  group('DiscoveredServerConfirmDialog.isInEmailDomain', () {
    test('SHOULD accept the email domain and its subdomains', () {
      expect(DiscoveredServerConfirmDialog.isInEmailDomain('corp.example', 'corp.example'), isTrue);
      expect(DiscoveredServerConfirmDialog.isInEmailDomain('JMAP.corp.example', 'corp.example'), isTrue);
    });

    test('SHOULD flag lookalike and unrelated servers', () {
      expect(DiscoveredServerConfirmDialog.isInEmailDomain('corp.example.attacker.net', 'corp.example'), isFalse);
      expect(DiscoveredServerConfirmDialog.isInEmailDomain('evilcorp.example', 'corp.example'), isFalse);
      expect(DiscoveredServerConfirmDialog.isInEmailDomain('jmap.twake.app', 'corp.example'), isFalse);
    });
  });
}
