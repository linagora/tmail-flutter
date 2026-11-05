import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_callback_action_define.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'login_controller_test.mocks.dart';

/// Records how a pending link is handed on, and runs the app-running callback
/// the way [DeepLinksManager] does.
class _RecordingDeepLinksManager extends Fake implements DeepLinksManager {
  final pending = BehaviorSubject<DeepLinkData?>.seeded(null);
  int openAppCalls = 0;
  int autoSignInCalls = 0;
  bool? signedIn;
  OpenAppDeepLinkData? opened;
  OnAutoSignInViaDeepLinkSuccessCallback? onAutoSignInSuccess;

  @override
  BehaviorSubject<DeepLinkData?> get pendingDeepLinkData => pending;

  @override
  void clearPendingDeepLinkData() {}

  @override
  Future<void> handleDeepLinksWhenAppRunning({
    required DeepLinkData? deepLinkData,
    required OnDeepLinkSuccessCallback onSuccessCallback,
    OnDeepLinkFailureCallback? onFailureCallback,
  }) async {
    if (deepLinkData == null) {
      onFailureCallback?.call();
      return;
    }
    onSuccessCallback(deepLinkData);
  }

  @override
  Future<void> handleOpenAppDeepLinks({
    required OpenAppDeepLinkData openAppDeepLinkData,
    OnDeepLinkFailureCallback? onFailureCallback,
    OnAutoSignInViaDeepLinkSuccessCallback? onAutoSignInSuccessCallback,
    OnDeepLinkConfirmLogoutCallback<OpenAppDeepLinkData>?
    onConfirmLogoutCallback,
    UserName? username,
    bool isSignedIn = true,
  }) async {
    openAppCalls++;
    opened = openAppDeepLinkData;
    signedIn = isSignedIn;
    onAutoSignInSuccess = onAutoSignInSuccessCallback;
  }

  @override
  Future<void> autoSignInViaDeepLink({
    required OpenAppDeepLinkData openAppDeepLinkData,
    required OnAutoSignInViaDeepLinkSuccessCallback onAutoSignInSuccessCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
    autoSignInCalls++;
  }
}

void main() {
  late _RecordingDeepLinksManager manager;
  late LoginController loginController;

  setUp(() {
    Get.put<GetSessionInteractor>(MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(
      MockGetAuthenticatedAccountInteractor(),
    );
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(MockGetOidcUserInfoInteractor());
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authorizationInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());
    Get.put<Uuid>(MockUuid());
    manager = _RecordingDeepLinksManager();
    Get.put<DeepLinksManager>(manager);
    Get.testMode = true;
    dotenv.testLoad(mergeWith: {'SERVER_URL': 'https://example.com'});

    loginController = LoginController(
      MockAuthenticationInteractor(),
      MockCheckOIDCIsAvailableInteractor(),
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
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: const Scaffold(),
        builder: FlutterSmartDialog.init(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> onPhone(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    // _registerDeepLinks runs only on a phone. The binding checks this flag
    // before tearDown, so it is cleared before this function returns.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await pumpApp(tester);
      loginController.onInit();
      await body();
    } finally {
      loginController.onClose();
      debugDefaultTargetPlatformOverride = null;
    }
  }

  final link = OpenAppDeepLinkData(
    registrationUrl: 'https://sign-up.twake.app',
    jmapUrl: 'https://jmap.twake.app',
    username: 'alice@twake.app',
    accessToken: 'token-1',
  );

  testWidgets(
    'SHOULD confirm an openApp link signed out and show loading only after sign-in succeeds',
    (tester) async {
      await onPhone(tester, () async {
        manager.pending.add(link);
        await tester.pump();

        expect(manager.openAppCalls, 1);
        expect(manager.opened, same(link));
        expect(manager.signedIn, isFalse);
        expect(manager.autoSignInCalls, 0);
        expect(find.text('Loading... Please wait!'), findsNothing);

        manager.onAutoSignInSuccess!(
          AutoSignInViaDeepLinkSuccess(
            link.tokenOIDC,
            link.baseUri,
            link.oidcConfiguration,
          ),
        );
        await tester.pump();

        expect(find.text('Loading... Please wait!'), findsOneWidget);
        expect(manager.autoSignInCalls, 0);
        await SmartDialog.dismiss();
        await tester.pumpAndSettle();
      });
    },
  );

  testWidgets('SHOULD ignore a pending link that is not an openApp sign-in', (
    tester,
  ) async {
    await onPhone(tester, () async {
      manager.pending.add(DeepLinkData(actionType: DeepLinkActionType.unknown));
      await tester.pump();

      expect(manager.openAppCalls, 0);
      expect(manager.autoSignInCalls, 0);
      expect(find.text('Loading... Please wait!'), findsNothing);
    });
  });
}
