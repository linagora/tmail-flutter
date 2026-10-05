import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class _RecordingAppToast extends AppToast {
  final List<String> errors = [];

  @override
  void showToastErrorMessage(
    BuildContext context,
    String message, {
    Color? leadingSVGIconColor,
    String? leadingSVGIcon,
    Duration? duration,
  }) => errors.add(message);
}

class _FakeAutoSignInInteractor extends Fake implements AutoSignInViaDeepLinkInteractor {
  int calls = 0;

  @override
  Stream<Either<Failure, Success>> execute({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration,
  }) {
    calls++;
    return Stream.value(Right<Failure, Success>(
      AutoSignInViaDeepLinkSuccess(tokenOIDC, baseUri, oidcConfiguration)));
  }
}

void main() {
  final deepLinkManager = DeepLinksManager();

  group('DeepLinksManager::test', () {
    group('parseDeepLink::test', () {
      test('SHOULD returns correct DeepLinkData for valid openApp deep link', () {
        const url = 'twake://openApp/some-data';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNotNull);
        expect(result?.actionType, DeepLinkActionType.openApp);
      });

      test('SHOULD returns DeepLinkData with unknown action for unhandled action', () {
        const url = 'twake://unknownAction/some-data';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNotNull);
        expect(result?.actionType, DeepLinkActionType.unknown);
      });

      test('SHOULD returns null for malformed URL', () {
        const url = 'Invalid link: invalid';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNull);
      });

      test('SHOULD returns null for exception during parsing', () {
        const url = 'twake://malformedurl%';
        final result = deepLinkManager.parseDeepLink(url);

        expect(result, isNull);
      });
    });

    group('parseOpenAppDeepLink::test', () {
      test('SHOULD returns OpenAppDeepLinkData with all valid parameters', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://sign-up.twake.app'
              '&jmapUrl=https://jmap.twake.app',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, 'refresh123');
        expect(result?.idToken, 'id123');
        expect(result?.expiresIn, 3600);
        expect(result?.username, 'user');
        expect(result?.registrationUrl, 'https://sign-up.twake.app');
        expect(result?.jmapUrl, 'https://jmap.twake.app');
        expect(result?.isValidAuthentication(), isTrue);
      });

      test('SHOULD returns OpenAppDeepLinkData with missing optional parameters', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=user@example.com'
              '&registrationUrl=https://sign-up.twake.app'
              '&jmapUrl=https://jmap.twake.app',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, isNull);
        expect(result?.idToken, isNull);
        expect(result?.expiresIn, isNull);
        expect(result?.username, 'user@example.com');
        expect(result?.registrationUrl, 'https://sign-up.twake.app');
        expect(result?.jmapUrl, 'https://jmap.twake.app');
        expect(result?.isValidAuthentication(), isTrue);
      });


      test('SHOULD returns OpenAppDeepLinkData with invalid expires_in', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&expires_in=not_a_number'
              '&registrationUrl=https://sign-up.twake.app'
              '&jmapUrl=https://jmap.twake.app',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.expiresIn, isNull);
      });

      test('SHOULD returns OpenAppDeepLinkData with origin username if Base64 decoding fails', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=invalid_base64'
              '&registrationUrl=https://sign-up.twake.app'
              '&jmapUrl=https://jmap.twake.app',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.username, 'invalid_base64');
      });

      test('SHOULD returns OpenAppDeepLinkData with jmapUrl contains sub-path and port', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://sign-up.twake.app'
              '&jmapUrl=https://jmap.twake.app:1000/jmap',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.jmapUrl, 'https://jmap.twake.app:1000/jmap');
      });

      test('SHOULD returns OpenAppDeepLinkData with registrationUrl contains sub-path and port', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://sign-up.twake.app:1000/register'
              '&jmapUrl=https://jmap.twake.app',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.registrationUrl, 'https://sign-up.twake.app:1000/register');
      });
    });
  });

  group('OpenAppDeepLinkData::isValidAuthentication', () {
    OpenAppDeepLinkData build({
      String registrationUrl = 'https://sign-up.twake.app',
      String jmapUrl = 'https://jmap.twake.app',
    }) => OpenAppDeepLinkData(
      registrationUrl: registrationUrl,
      jmapUrl: jmapUrl,
      username: 'alice@example.com',
      accessToken: 'token',
    );

    test('SHOULD accept https servers', () {
      expect(build().isValidAuthentication(), isTrue);
    });

    test('SHOULD refuse a plain http JMAP server', () {
      expect(build(jmapUrl: 'http://jmap.twake.app').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse a plain http identity provider', () {
      expect(build(registrationUrl: 'http://sign-up.twake.app').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse non absolute URLs', () {
      expect(build(jmapUrl: 'jmap.twake.app').isValidAuthentication(), isFalse);
      expect(build(registrationUrl: 'javascript:alert(1)').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse https URLs without a host', () {
      expect(build(jmapUrl: 'https:/jmap.twake.app').isValidAuthentication(), isFalse);
      expect(build(registrationUrl: 'https:sign-up.twake.app').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse https servers outside the allow-list', () {
      expect(build(jmapUrl: 'https://evil.com').isValidAuthentication(), isFalse);
      expect(build(registrationUrl: 'https://evil.com').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse a subdomain of an allowed host', () {
      expect(build(jmapUrl: 'https://evil.jmap.twake.app').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse a backslash that other URL parsers read as user info', () {
      expect(build(registrationUrl: r'https://sign-up.twake.app\@evil.com').isValidAuthentication(), isFalse);
      expect(build(jmapUrl: r'https://jmap.twake.app\@evil.com').isValidAuthentication(), isFalse);
    });

    test('SHOULD expose the JMAP host for user confirmation', () {
      expect(build().jmapHost, 'jmap.twake.app');
    });

    test('SHOULD fall back to the raw value WHEN the JMAP URL is unparsable', () {
      expect(build(jmapUrl: 'http://[::1').jmapHost, 'http://[::1');
    });
  });

  group('DeepLinksManager::autoSignInViaDeepLink', () {
    late _FakeAutoSignInInteractor interactor;

    OpenAppDeepLinkData link({String jmapUrl = 'https://jmap.twake.app'}) => OpenAppDeepLinkData(
      registrationUrl: 'https://sign-up.twake.app',
      jmapUrl: jmapUrl,
      username: 'alice@example.com',
      accessToken: 'token',
    );

    setUp(() {
      interactor = _FakeAutoSignInInteractor();
      Get.put<AutoSignInViaDeepLinkInteractor>(interactor);
    });

    tearDown(Get.reset);

    test('SHOULD NOT call the interactor WHEN the JMAP URL is http', () async {
      var failed = false;

      await deepLinkManager.autoSignInViaDeepLink(
        openAppDeepLinkData: link(jmapUrl: 'http://jmap.twake.app'),
        onAutoSignInSuccessCallback: (_) {},
        onFailureCallback: () => failed = true,
      );

      expect(failed, isTrue);
      expect(interactor.calls, 0);
    });

    test('SHOULD NOT call the interactor WHEN the JMAP host is not allowed', () async {
      var failed = false;

      await deepLinkManager.autoSignInViaDeepLink(
        openAppDeepLinkData: link(jmapUrl: 'https://evil.com'),
        onAutoSignInSuccessCallback: (_) {},
        onFailureCallback: () => failed = true,
      );

      expect(failed, isTrue);
      expect(interactor.calls, 0);
    });

    test('SHOULD call the interactor once WHEN the JMAP URL is https', () async {
      AutoSignInViaDeepLinkSuccess? success;

      await deepLinkManager.autoSignInViaDeepLink(
        openAppDeepLinkData: link(),
        onAutoSignInSuccessCallback: (state) => success = state,
        onFailureCallback: () => fail('should not fail'),
      );

      expect(interactor.calls, 1);
      expect(success?.baseUri, Uri.parse('https://jmap.twake.app'));
    });
  });

  group('DeepLinksManager::handleOpenAppDeepLinks', () {
    setUp(() {
      Get.put(ResponsiveUtils());
      Get.put(ImagePaths());
    });

    tearDown(Get.reset);

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        home: Scaffold(),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'SHOULD show the collapsed link username and the JMAP host '
      'in the switch account dialog WHEN signed in with another account',
      (tester) async {
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: OpenAppDeepLinkData(
            registrationUrl: 'https://sign-up.twake.app',
            jmapUrl: 'https://jmap.twake.app/jmap',
            username: 'alice\n\n\n@example.com',
            accessToken: 'token',
          ),
          username: UserName('bob@example.com'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(' alice @example.com (jmap.twake.app)?')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SHOULD strip bidi overrides from the link username '
      'so the JMAP host cannot be faked in the switch account dialog',
      (tester) async {
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: OpenAppDeepLinkData(
            registrationUrl: 'https://sign-up.twake.app',
            jmapUrl: 'https://jmap.twake.app/jmap',
            username: 'alice@twake.app (sign-up.twake.app)\u202E',
            accessToken: 'token',
          ),
          username: UserName('bob@example.com'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(' alice@twake.app (sign-up.twake.app) (jmap.twake.app)?')),
          findsOneWidget,
        );
      },
    );

    testWidgets('SHOULD show a toast WHEN the link is refused', (tester) async {
      final toast = Get.put<AppToast>(_RecordingAppToast()) as _RecordingAppToast;
      await pumpApp(tester);
      var failed = false;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: OpenAppDeepLinkData(
          registrationUrl: 'https://sign-up.twake.app',
          jmapUrl: 'https://evil.com',
          username: 'alice@example.com',
          accessToken: 'token',
        ),
        username: UserName('bob@example.com'),
        onFailureCallback: () => failed = true,
      );
      await tester.pump();

      expect(toast.errors, ['This sign-in link isn\'t from Twake. Please sign in from the app.']);
      expect(failed, isTrue);
    });

    testWidgets(
      'SHOULD show a toast WHEN autoSignInViaDeepLink refuses the link while signed out',
      (tester) async {
        final toast = Get.put<AppToast>(_RecordingAppToast()) as _RecordingAppToast;
        await pumpApp(tester);
        var failed = false;

        await deepLinkManager.autoSignInViaDeepLink(
          openAppDeepLinkData: OpenAppDeepLinkData(
            registrationUrl: 'https://sign-up.twake.app',
            jmapUrl: 'https://evil.com',
            username: 'alice@example.com',
            accessToken: 'token',
          ),
          onAutoSignInSuccessCallback: (_) {},
          onFailureCallback: () => failed = true,
        );

        expect(toast.errors, ['This sign-in link isn\'t from Twake. Please sign in from the app.']);
        expect(failed, isTrue);
      },
    );

    testWidgets('SHOULD still call the failure callback WHEN no AppToast is registered', (tester) async {
      await pumpApp(tester);
      var failed = false;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: OpenAppDeepLinkData(
          registrationUrl: 'https://sign-up.twake.app',
          jmapUrl: 'https://evil.com',
          username: 'alice@example.com',
          accessToken: 'token',
        ),
        username: UserName('bob@example.com'),
        onFailureCallback: () => failed = true,
      );

      expect(failed, isTrue);
    });

    // The web "Open in app" banner (web/worker_service/worker_service.js) opens
    // twakemail.mobile://openapp with no parameters: it only brings the app up.
    testWidgets(
      'SHOULD NOT show the refused-link toast WHEN a bare openapp link arrives while signed in',
      (tester) async {
        final toast = Get.put<AppToast>(_RecordingAppToast()) as _RecordingAppToast;
        await pumpApp(tester);
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData:
              deepLinkManager.parseDeepLink('twakemail.mobile://openapp') as OpenAppDeepLinkData,
          username: UserName('bob@example.com'),
          onFailureCallback: () => failed = true,
        );
        await tester.pump();

        expect(toast.errors, isEmpty);
        expect(failed, isTrue);
      },
    );

    testWidgets(
      'SHOULD NOT show the refused-link toast WHEN a bare openapp link arrives while signed out',
      (tester) async {
        final toast = Get.put<AppToast>(_RecordingAppToast()) as _RecordingAppToast;
        await pumpApp(tester);
        var failed = false;

        await deepLinkManager.autoSignInViaDeepLink(
          openAppDeepLinkData:
              deepLinkManager.parseDeepLink('twakemail.mobile://openapp') as OpenAppDeepLinkData,
          onAutoSignInSuccessCallback: (_) {},
          onFailureCallback: () => failed = true,
        );

        expect(toast.errors, isEmpty);
        expect(failed, isTrue);
      },
    );

    const hiddenCharacters = [
      '\u0000', '\u001B', '\u007F', '\u009B',
      '\u061C', '\u200E', '\u200F',
      '\u202A', '\u202E', '\u2066', '\u2067', '\u2069',
      '\u2028', '\u3000',
    ];

    for (final char in hiddenCharacters) {
      final codePoint = char.codeUnitAt(0).toRadixString(16).toUpperCase().padLeft(4, '0');

      testWidgets(
        'SHOULD replace U+$codePoint in the link username with a single space '
        'in the switch account dialog',
        (tester) async {
          await pumpApp(tester);

          deepLinkManager.handleOpenAppDeepLinks(
            openAppDeepLinkData: OpenAppDeepLinkData(
              registrationUrl: 'https://sign-up.twake.app',
              jmapUrl: 'https://jmap.twake.app/jmap',
              username: 'alice@twake.app$char$char(sign-up.twake.app)$char',
              accessToken: 'token',
            ),
            username: UserName('bob@example.com'),
          );
          await tester.pumpAndSettle();

          expect(
            find.byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains(' alice@twake.app (sign-up.twake.app) (jmap.twake.app)?')),
            findsOneWidget,
          );
        },
      );
    }
  });
}
