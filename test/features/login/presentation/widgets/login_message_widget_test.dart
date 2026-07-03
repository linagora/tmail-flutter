import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_message_widget.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

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

void main() {
  group('LoginMessageWidget::ssoRedirectFailedMessage gating', () {
    testWidgets(
        'GetTokenOIDCFailure with ssoConfirmed == true shows the SSO message',
        (tester) async {
      await _pump(tester, Left(GetTokenOIDCFailure(Exception(), ssoConfirmed: true)));

      expect(_renderedMessage(tester), _appLocalizations!.ssoRedirectFailedMessage);
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure with ssoConfirmed == true shows the SSO message',
        (tester) async {
      await _pump(tester,
          Left(AuthenticateOidcOnBrowserFailure(Exception(), ssoConfirmed: true)));

      expect(_renderedMessage(tester), _appLocalizations!.ssoRedirectFailedMessage);
    });

    testWidgets(
        'GetTokenOIDCFailure with ssoConfirmed == false does NOT show the SSO message',
        (tester) async {
      await _pump(tester, Left(GetTokenOIDCFailure(Exception(), ssoConfirmed: false)));

      expect(_renderedMessage(tester),
          isNot(_appLocalizations!.ssoRedirectFailedMessage));
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure with ssoConfirmed == false does NOT show the SSO message',
        (tester) async {
      await _pump(tester,
          Left(AuthenticateOidcOnBrowserFailure(Exception(), ssoConfirmed: false)));

      expect(_renderedMessage(tester),
          isNot(_appLocalizations!.ssoRedirectFailedMessage));
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
          isNot(_appLocalizations!.ssoRedirectFailedMessage));
    });

    testWidgets(
        'AuthenticateOidcOnBrowserFailure(ssoConfirmed) with a NetworkException does NOT show the SSO message',
        (tester) async {
      await _pump(tester, Left(AuthenticateOidcOnBrowserFailure(
        const ConnectionError(),
        ssoConfirmed: true,
      )));

      expect(_renderedMessage(tester),
          isNot(_appLocalizations!.ssoRedirectFailedMessage));
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
  });
}
