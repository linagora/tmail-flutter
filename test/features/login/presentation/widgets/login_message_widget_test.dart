import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_message_widget.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';

/// Captured localizations from the last pumped widget, so tests can assert
/// against the resolved strings rather than hard-coding them.
AppLocalizations? _appLocalizations;

Widget _makeTestableWidget(Either<Failure, Success> viewState) {
  return GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(
      body: Builder(builder: (context) {
        _appLocalizations = AppLocalizations.of(context);
        return LoginMessageWidget(
          formType: LoginFormType.retry,
          viewState: viewState,
        );
      }),
    ),
  );
}

String _renderedMessage(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byType(LoginMessageWidget),
      matching: find.byType(Text),
    ),
  );
  return text.data ?? '';
}

Future<void> _pump(WidgetTester tester, Either<Failure, Success> viewState) async {
  await tester.pumpWidget(_makeTestableWidget(viewState));
  await tester.pumpAndSettle();
}

class _MinifiedLikeException implements Exception {
  @override
  String toString() => "Instance of 'minified:aHb'";
}

void _runAsWeb() {
  PlatformInfo.isTestingForWeb = true;
  addTearDown(() => PlatformInfo.isTestingForWeb = false);
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ImagePaths>(ImagePaths());
    Get.put<AppToast>(AppToast());
    Get.put<ToastManager>(
      ToastManager(
        Get.find<AppToast>(),
        Get.find<ImagePaths>(),
      ),
    );
  });

  tearDown(Get.reset);

  group('LoginMessageWidget::SSO redirect failure gating', () {
    testWidgets(
        'GetTokenOIDCFailure(ssoConfirmed) with an unknown exception is silent',
        (tester) async {
      _runAsWeb();
      // On app open this is the silent re-authentication redirecting to the SSO
      // page, so a bare "unexpected error" must not flash on the login screen.
      await _pump(tester, Left(GetTokenOIDCFailure(
        _MinifiedLikeException(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), isEmpty);
    });

    testWidgets(
        'GetTokenOIDCFailure(ssoConfirmed) with an unknown exception outside web is NOT silent',
        (tester) async {
      PlatformInfo.isTestingForWeb = false;
      await _pump(tester, Left(GetTokenOIDCFailure(
        _MinifiedLikeException(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), isNotEmpty);
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure(ssoConfirmed) with an unknown exception is silent',
        (tester) async {
      _runAsWeb();
      await _pump(tester, Left(AuthenticateOidcOnBrowserFailure(
        _MinifiedLikeException(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), isEmpty);
    });

    testWidgets(
        'GetTokenOIDCFailure(ssoConfirmed) with AutoRedirect exception is silent',
        (tester) async {
      // A null token response (SSO redirect just initiated) surfaces this
      // exception, which resolves to an empty message so nothing flashes.
      await _pump(tester, Left(GetTokenOIDCFailure(
        AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), isEmpty);
    });

    testWidgets(
        'known GetTokenOIDCFailure(ssoConfirmed) still surfaces its specific message',
        (tester) async {
      // A confirmed-SSO failure with a known exception is not silenced: the
      // specific message (e.g. a network drop) still reaches the user.
      await _pump(tester, Left(GetTokenOIDCFailure(
        CanNotFoundBaseUrl(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), _appLocalizations!.requiredUrl);
    });

    testWidgets(
        'GetTokenOIDCFailure with ssoConfirmed == false is NOT silenced',
        (tester) async {
      // A guessed (unconfirmed) provider falls back to basic auth, so its
      // redirect failure must still surface a message instead of going silent.
      await _pump(tester, Left(GetTokenOIDCFailure(
        _MinifiedLikeException(),
        ssoConfirmed: false,
      )));

      expect(_renderedMessage(tester), isNotEmpty);
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure with ssoConfirmed == false is NOT silenced',
        (tester) async {
      await _pump(tester, Left(AuthenticateOidcOnBrowserFailure(
        _MinifiedLikeException(),
        ssoConfirmed: false,
      )));

      expect(_renderedMessage(tester), isNotEmpty);
    });

    testWidgets(
        'GetTokenOIDCFailure(ssoConfirmed) with a NetworkException does NOT show the SSO message',
        (tester) async {
      // A network drop mid-redirect must surface as offline/connection, not as
      // a blamed SSO redirect.
      await _pump(tester, Left(GetTokenOIDCFailure(
        const ConnectionError(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester),
          _appLocalizations!.connectionError);
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure(ssoConfirmed) with a NetworkException does NOT show the SSO message',
        (tester) async {
      await _pump(tester, Left(AuthenticateOidcOnBrowserFailure(
        const ConnectionError(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester),
          _appLocalizations!.connectionError);
    });

    testWidgets(
        'NoSuitableBrowserForOIDCException wins over the SSO message',
        (tester) async {
      await _pump(tester, Left(GetTokenOIDCFailure(
        NoSuitableBrowserForOIDCException(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester), _appLocalizations!.noSuitableBrowserForOIDC);
    });

    testWidgets(
        'GetAuthenticationInfoFailure is silent while web login continues re-auth',
        (tester) async {
      _runAsWeb();
      await _pump(tester, Left(GetAuthenticationInfoFailure(
        _MinifiedLikeException(),
      )));

      expect(_renderedMessage(tester), isEmpty);
    });

    testWidgets(
        'GetAuthenticatedAccountFailure is silent while web login continues re-auth',
        (tester) async {
      _runAsWeb();
      await _pump(tester, Left(GetAuthenticatedAccountFailure(
        _MinifiedLikeException(),
      )));

      expect(_renderedMessage(tester), isEmpty);
    });

    testWidgets(
        'known GetTokenOIDCFailure message is still displayed',
        (tester) async {
      await _pump(tester, Left(GetTokenOIDCFailure(
        CanNotFoundBaseUrl(),
        ssoConfirmed: false,
      )));

      expect(_renderedMessage(tester), _appLocalizations!.requiredUrl);
    });
  });
}
