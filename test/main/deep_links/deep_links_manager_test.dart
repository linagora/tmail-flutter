import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, 'refresh123');
        expect(result?.idToken, 'id123');
        expect(result?.expiresIn, 3600);
        expect(result?.username, 'user');
        expect(result?.registrationUrl, 'https://registration.url');
        expect(result?.jmapUrl, 'https://jmap.url');
        expect(result?.isValidAuthentication(), isTrue);
      });

      test('SHOULD returns OpenAppDeepLinkData with missing optional parameters', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=user@example.com'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.accessToken, 'token123');
        expect(result?.refreshToken, isNull);
        expect(result?.idToken, isNull);
        expect(result?.expiresIn, isNull);
        expect(result?.username, 'user@example.com');
        expect(result?.registrationUrl, 'https://registration.url');
        expect(result?.jmapUrl, 'https://jmap.url');
        expect(result?.isValidAuthentication(), isTrue);
      });


      test('SHOULD returns OpenAppDeepLinkData with invalid expires_in', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&expires_in=not_a_number'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.expiresIn, isNull);
      });

      test('SHOULD returns OpenAppDeepLinkData with origin username if Base64 decoding fails', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&username=invalid_base64'
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url',
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
              '&registrationUrl=https://registration.url'
              '&jmapUrl=https://jmap.url:1000/jmap',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.jmapUrl, 'https://jmap.url:1000/jmap');
      });

      test('SHOULD returns OpenAppDeepLinkData with registrationUrl contains sub-path and port', () {
        final uri = Uri.parse(
          'twake://openApp?access_token=token123'
              '&refresh_token=refresh123'
              '&id_token=id123'
              '&expires_in=3600'
              '&username=dXNlcg=='
              '&registrationUrl=https://registration.url:1000/register'
              '&jmapUrl=https://jmap.url',
        );

        final result = deepLinkManager.parseOpenAppDeepLink(uri);

        expect(result, isNotNull);
        expect(result?.registrationUrl, 'https://registration.url:1000/register');
      });
    });
  });

  group('OpenAppDeepLinkData::isValidAuthentication', () {
    OpenAppDeepLinkData build({
      String registrationUrl = 'https://sso.example.com',
      String jmapUrl = 'https://jmap.example.com',
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
      expect(build(jmapUrl: 'http://jmap.example.com').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse a plain http identity provider', () {
      expect(build(registrationUrl: 'http://sso.example.com').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse non absolute URLs', () {
      expect(build(jmapUrl: 'jmap.example.com').isValidAuthentication(), isFalse);
      expect(build(registrationUrl: 'javascript:alert(1)').isValidAuthentication(), isFalse);
    });

    test('SHOULD refuse https URLs without a host', () {
      expect(build(jmapUrl: 'https:/jmap.example.com').isValidAuthentication(), isFalse);
      expect(build(registrationUrl: 'https:sso.example.com').isValidAuthentication(), isFalse);
    });

    test('SHOULD expose the JMAP host for user confirmation', () {
      expect(build().jmapHost, 'jmap.example.com');
    });

    test('SHOULD fall back to the raw value WHEN the JMAP URL is unparsable', () {
      expect(build(jmapUrl: 'http://[::1').jmapHost, 'http://[::1');
    });
  });

  group('DeepLinksManager::autoSignInViaDeepLink', () {
    late _FakeAutoSignInInteractor interactor;

    OpenAppDeepLinkData link({String jmapUrl = 'https://jmap.example.com'}) => OpenAppDeepLinkData(
      registrationUrl: 'https://sso.example.com',
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
        openAppDeepLinkData: link(jmapUrl: 'http://jmap.example.com'),
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
      expect(success?.baseUri, Uri.parse('https://jmap.example.com'));
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
            registrationUrl: 'https://sso.example.com',
            jmapUrl: 'https://jmap.example.com/jmap',
            username: 'alice\n\n\n@example.com',
            accessToken: 'token',
          ),
          username: UserName('bob@example.com'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(' alice @example.com (jmap.example.com)?')),
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
            registrationUrl: 'https://sso.example.com',
            jmapUrl: 'https://jmap.example.com/jmap',
            username: 'alice@twake.app (jmap.twake.app)\u202E',
            accessToken: 'token',
          ),
          username: UserName('bob@example.com'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(' alice@twake.app (jmap.twake.app) (jmap.example.com)?')),
          findsOneWidget,
        );
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
              registrationUrl: 'https://sso.example.com',
              jmapUrl: 'https://jmap.example.com/jmap',
              username: 'alice@twake.app$char$char(jmap.twake.app)$char',
              accessToken: 'token',
            ),
            username: UserName('bob@example.com'),
          );
          await tester.pumpAndSettle();

          expect(
            find.byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains(' alice@twake.app (jmap.twake.app) (jmap.example.com)?')),
            findsOneWidget,
          );
        },
      );
    }
  });
}
