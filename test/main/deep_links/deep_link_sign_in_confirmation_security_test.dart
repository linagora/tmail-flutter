import 'dart:async';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_account_verifier.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

/// Records the messages of error toasts.
class _RecordingAppToast extends Fake implements AppToast {
  final List<String> errors = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #showToastErrorMessage) {
      errors.add(invocation.positionalArguments[1] as String);
    }
    return null;
  }
}

/// Stands in for the JMAP session request: the server reports [username]
/// as the account of the link token.
class _FakeAccountVerifier extends DeepLinkAccountVerifier {
  _FakeAccountVerifier(this.username);

  final String username;
  int calls = 0;

  @override
  Future<String> getAccountUsername(OpenAppDeepLinkData data) async {
    calls++;
    return username;
  }
}

/// Fails with [errors] in turn, then reports alice@twake.app.
class _FailingAccountVerifier extends DeepLinkAccountVerifier {
  _FailingAccountVerifier(this.errors);

  final List<Object> errors;
  int calls = 0;

  @override
  Future<String> getAccountUsername(OpenAppDeepLinkData data) async {
    calls++;
    if (errors.isNotEmpty) throw errors.removeAt(0);
    return 'alice@twake.app';
  }
}

/// Answers only when the test completes it, so the test can act while the
/// link is being verified.
class _PendingAccountVerifier extends DeepLinkAccountVerifier {
  final Completer<String> _result = Completer();

  void succeed(String username) => _result.complete(username);

  void fail(Object error) => _result.completeError(error);

  @override
  Future<String> getAccountUsername(OpenAppDeepLinkData data) => _result.future;
}

DioException _dioError(DioExceptionType type, {int? statusCode}) => DioException(
  requestOptions: RequestOptions(path: '/.well-known/jmap'),
  type: type,
  response: statusCode == null
      ? null
      : Response(requestOptions: RequestOptions(path: '/.well-known/jmap'), statusCode: statusCode),
);

class _CountingAutoSignInInteractor extends Fake implements AutoSignInViaDeepLinkInteractor {
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

class _FailingAutoSignInInteractor extends Fake implements AutoSignInViaDeepLinkInteractor {
  int calls = 0;

  @override
  Stream<Either<Failure, Success>> execute({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration,
  }) {
    calls++;
    return Stream.value(Left<Failure, Success>(
      AutoSignInViaDeepLinkFailure('sign-in failed')));
  }
}

class _PendingAutoSignInInteractor extends Fake implements AutoSignInViaDeepLinkInteractor {
  final Completer<Either<Failure, Success>> _result = Completer();

  void complete() => _result.complete(Left(AutoSignInViaDeepLinkFailure('sign-in failed')));

  @override
  Stream<Either<Failure, Success>> execute({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration,
  }) => Stream.fromFuture(_result.future);
}

OpenAppDeepLinkData _link({
  String username = 'alice@twake.app',
  String accessToken = 'token-1',
}) => OpenAppDeepLinkData(
  registrationUrl: 'https://sign-up.twake.app',
  jmapUrl: 'https://jmap.twake.app',
  username: username,
  accessToken: accessToken,
);

void main() {
  late DeepLinksManager deepLinkManager;
  late _CountingAutoSignInInteractor interactor;
  late _RecordingAppToast toast;

  setUp(() {
    deepLinkManager = DeepLinksManager();
    interactor = _CountingAutoSignInInteractor();
    toast = _RecordingAppToast();
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
    Get.put<AppToast>(toast);
    Get.put<AutoSignInViaDeepLinkInteractor>(interactor);
    Get.put<DeepLinkAccountVerifier>(_FakeAccountVerifier('alice@twake.app'));
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: const Scaffold(),
      builder: FlutterSmartDialog.init(),
    ));
    await tester.pumpAndSettle();
  }

  final signInDialog = find.byKey(const Key('confirm_sign_in_with_link_dialog'));

  group('signed out', () {
    testWidgets(
      'SHOULD ask for confirmation with the server account '
      'and store nothing before the user confirms',
      (tester) async {
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
        );
        await tester.pumpAndSettle();

        expect(signInDialog, findsOneWidget);
        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('alice@twake.app (jmap.twake.app)')),
          findsOneWidget,
        );
        expect(interactor.calls, 0);
      },
    );

    testWidgets('SHOULD sign in once WHEN the user confirms', (tester) async {
      await pumpApp(tester);
      AutoSignInViaDeepLinkSuccess? signedIn;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: _link(),
        isSignedIn: false,
        onAutoSignInSuccessCallback: (success) => signedIn = success,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(interactor.calls, 1);
      expect(signedIn?.tokenOIDC.token, 'token-1');
    });

    testWidgets(
      'SHOULD report the failure WHEN the user confirms and sign-in fails',
      (tester) async {
        final failing = _FailingAutoSignInInteractor();
        Get.replace<AutoSignInViaDeepLinkInteractor>(failing);
        await pumpApp(tester);
        var failures = 0;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          onFailureCallback: () => failures++,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(failing.calls, 1);
        expect(failures, 1);
      },
    );

    testWidgets('SHOULD store nothing WHEN the user cancels', (tester) async {
      await pumpApp(tester);
      var failed = false;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: _link(),
        isSignedIn: false,
        onFailureCallback: () => failed = true,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(interactor.calls, 0);
      expect(failed, isTrue);
    });

    testWidgets(
      'SHOULD treat closing the dialog without a button as a cancel',
      (tester) async {
        await pumpApp(tester);
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          onFailureCallback: () => failed = true,
        );
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
        expect(failed, isTrue);
      },
    );

    testWidgets(
      'SHOULD refuse the link WHEN its username is not the account of its token',
      (tester) async {
        Get.replace<DeepLinkAccountVerifier>(_FakeAccountVerifier('attacker@twake.app'));
        await pumpApp(tester);
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'alice@twake.app'),
          isSignedIn: false,
          onFailureCallback: () => failed = true,
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
        expect(failed, isTrue);
        expect(toast.errors, ['We couldn\'t verify this sign-in link. Please sign in from the app.']);
      },
    );

    testWidgets('SHOULD refuse the link WHEN the server cannot be reached', (tester) async {
      Get.replace<DeepLinkAccountVerifier>(_FailingAccountVerifier([Exception('network down')]));
      await pumpApp(tester);
      var failed = false;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: _link(),
        isSignedIn: false,
        onFailureCallback: () => failed = true,
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));

      expect(signInDialog, findsNothing);
      expect(interactor.calls, 0);
      expect(failed, isTrue);
    });

    testWidgets(
      'SHOULD ask again for the same link WHEN the account check failed for a transient reason',
      (tester) async {
        final verifier = _FailingAccountVerifier([_dioError(DioExceptionType.connectionTimeout)]);
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        expect(signInDialog, findsNothing);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 2);
        expect(signInDialog, findsOneWidget);
        expect(interactor.calls, 0);
      },
    );

    testWidgets('SHOULD NOT check again a link WHEN the server answered 403', (tester) async {
      final verifier = _FailingAccountVerifier([
        _dioError(DioExceptionType.badResponse, statusCode: 403),
      ]);
      Get.replace<DeepLinkAccountVerifier>(verifier);
      await pumpApp(tester);

      deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
      await tester.pumpAndSettle();
      deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
      await tester.pumpAndSettle();

      expect(verifier.calls, 1);
      expect(toast.errors, hasLength(1));
      expect(signInDialog, findsNothing);
    });

    testWidgets(
      'SHOULD ask again for the same link WHEN the server answered 500',
      (tester) async {
        final verifier = _FailingAccountVerifier([
          _dioError(DioExceptionType.badResponse, statusCode: 500),
        ]);
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        expect(signInDialog, findsNothing);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 2);
        expect(signInDialog, findsOneWidget);
        expect(interactor.calls, 0);
      },
    );

    testWidgets(
      'SHOULD ask again for the same link WHEN the session had no username',
      (tester) async {
        final verifier = _FailingAccountVerifier([
          StateError('The JMAP session has no username'),
        ]);
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        expect(signInDialog, findsNothing);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 2);
        expect(signInDialog, findsOneWidget);
        expect(interactor.calls, 0);
      },
    );

    testWidgets(
      'SHOULD ask again for the same link WHEN there was no screen to confirm on',
      (tester) async {
        final verifier = _FakeAccountVerifier('alice@twake.app');
        Get.replace<DeepLinkAccountVerifier>(verifier);

        // Get.context is null until a screen is mounted, so this attempt cannot confirm.
        await deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
        );

        await pumpApp(tester);
        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 2);
        expect(signInDialog, findsOneWidget);
        expect(interactor.calls, 0);
      },
    );

    testWidgets(
      'SHOULD NOT check again a link whose token the server refused',
      (tester) async {
        final verifier = _FailingAccountVerifier([
          _dioError(DioExceptionType.badResponse, statusCode: 401),
        ]);
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 1);
        expect(toast.errors, hasLength(1));
        expect(signInDialog, findsNothing);
      },
    );

    testWidgets(
      'SHOULD NOT check again a link whose username is not the account of its token',
      (tester) async {
        final verifier = _FakeAccountVerifier('attacker@twake.app');
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();

        expect(verifier.calls, 1);
        expect(toast.errors, hasLength(1));
      },
    );

    testWidgets(
      'SHOULD NOT prompt again for a link the user already cancelled',
      (tester) async {
        await pumpApp(tester);
        var failures = 0;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          onFailureCallback: () => failures++,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Home is rebuilt and reads the same launch link again.
        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          onFailureCallback: () => failures++,
        );
        await tester.pumpAndSettle();

        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
        expect(failures, 2);
      },
    );

    testWidgets(
      'SHOULD show one dialog WHEN a second link arrives while confirming',
      (tester) async {
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
        );
        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(accessToken: 'token-2'),
          isSignedIn: false,
        );
        await tester.pumpAndSettle();

        expect(signInDialog, findsOneWidget);
      },
    );

    testWidgets(
      'SHOULD drop the link silently WHEN the caller closed while the link was verified',
      (tester) async {
        await pumpApp(tester);
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          isCallerActive: () => false,
          onFailureCallback: () => failed = true,
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
        expect(failed, isFalse);
      },
    );

    testWidgets(
      'SHOULD NOT ask WHEN the caller closed while a successful verification was pending',
      (tester) async {
        final verifier = _PendingAccountVerifier();
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);
        var isCallerActive = true;
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          isCallerActive: () => isCallerActive,
          onFailureCallback: () => failed = true,
        );
        await tester.pump();

        isCallerActive = false;
        verifier.succeed('alice@twake.app');
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
        expect(failed, isFalse);
      },
    );

    testWidgets(
      'SHOULD NOT run the failure callback WHEN the caller closed '
      'while a failing verification was pending',
      (tester) async {
        final verifier = _PendingAccountVerifier();
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);
        var isCallerActive = true;
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          isCallerActive: () => isCallerActive,
          onFailureCallback: () => failed = true,
        );
        await tester.pump();

        isCallerActive = false;
        verifier.fail(_dioError(DioExceptionType.connectionTimeout));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(failed, isFalse);
        expect(signInDialog, findsNothing);
        expect(interactor.calls, 0);
      },
    );

    testWidgets(
      'SHOULD run the failure callback WHEN the caller is still open '
      'after a failing verification',
      (tester) async {
        final verifier = _PendingAccountVerifier();
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);
        var failed = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(),
          isSignedIn: false,
          isCallerActive: () => true,
          onFailureCallback: () => failed = true,
        );
        await tester.pump();

        verifier.fail(_dioError(DioExceptionType.connectionTimeout));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(failed, isTrue);
      },
    );

    testWidgets(
      'SHOULD refuse a second link WHEN the confirmed sign-in is still running',
      (tester) async {
        final pending = _PendingAutoSignInInteractor();
        Get.replace<AutoSignInViaDeepLinkInteractor>(pending);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(openAppDeepLinkData: _link(), isSignedIn: false);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(accessToken: 'token-2'),
          isSignedIn: false,
        );
        await tester.pumpAndSettle();

        expect(Get.find<DeepLinkAccountVerifier>(), isA<_FakeAccountVerifier>()
          .having((verifier) => verifier.calls, 'calls', 1));
        expect(signInDialog, findsNothing);

        pending.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('signed in', () {
    testWidgets(
      'SHOULD NOT offer a switch WHEN the link account only differs by hidden characters',
      (tester) async {
        const lookalike = 'alice@twake.app‎';
        Get.replace<DeepLinkAccountVerifier>(_FakeAccountVerifier(lookalike));
        await pumpApp(tester);
        var ignored = false;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: lookalike),
          username: UserName('alice@twake.app'),
          onFailureCallback: () => ignored = true,
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(Dialog), findsNothing);
        expect(ignored, isTrue);
      },
    );

    testWidgets(
      'SHOULD ask the account reported by the server in the switch dialog',
      (tester) async {
        Get.replace<DeepLinkAccountVerifier>(_FakeAccountVerifier('bob@twake.app'));
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'BOB@twake.app'),
          username: UserName('alice@twake.app'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(' bob@twake.app (jmap.twake.app)?')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SHOULD log out to the link WHEN the user confirms the switch',
      (tester) async {
        Get.replace<DeepLinkAccountVerifier>(_FakeAccountVerifier('bob@twake.app'));
        await pumpApp(tester);
        final link = _link(username: 'bob@twake.app');
        var failures = 0;
        OpenAppDeepLinkData? loggedOut;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: link,
          username: UserName('alice@twake.app'),
          onConfirmLogoutCallback: (data) async => loggedOut = data,
          onFailureCallback: () => failures++,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        expect(loggedOut, same(link));
        expect(failures, 0);
        expect(interactor.calls, 0);
      },
    );

    testWidgets('SHOULD stay signed in WHEN the user cancels the switch', (tester) async {
      Get.replace<DeepLinkAccountVerifier>(_FakeAccountVerifier('bob@twake.app'));
      await pumpApp(tester);
      var failures = 0;
      var loggedOut = 0;

      deepLinkManager.handleOpenAppDeepLinks(
        openAppDeepLinkData: _link(username: 'bob@twake.app'),
        username: UserName('alice@twake.app'),
        onConfirmLogoutCallback: (_) async => loggedOut++,
        onFailureCallback: () => failures++,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(failures, 1);
      expect(loggedOut, 0);
      expect(interactor.calls, 0);
    });

    testWidgets(
      'SHOULD refuse a second link WHEN the confirmed switch is still running',
      (tester) async {
        final verifier = _FakeAccountVerifier('bob@twake.app');
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);
        final switchDone = Completer<void>();
        var switches = 0;

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'bob@twake.app'),
          username: UserName('alice@twake.app'),
          onConfirmLogoutCallback: (_) {
            switches++;
            return switchDone.future;
          },
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'bob@twake.app', accessToken: 'token-2'),
          username: UserName('alice@twake.app'),
          onConfirmLogoutCallback: (_) async => switches++,
        );
        await tester.pumpAndSettle();

        expect(verifier.calls, 1);
        expect(find.byType(Dialog), findsNothing);
        expect(switches, 1);

        switchDone.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'SHOULD accept a new link WHEN the previous switch has completed',
      (tester) async {
        final verifier = _FakeAccountVerifier('bob@twake.app');
        Get.replace<DeepLinkAccountVerifier>(verifier);
        await pumpApp(tester);

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'bob@twake.app'),
          username: UserName('alice@twake.app'),
          onConfirmLogoutCallback: (_) async {},
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        deepLinkManager.handleOpenAppDeepLinks(
          openAppDeepLinkData: _link(username: 'bob@twake.app', accessToken: 'token-2'),
          username: UserName('alice@twake.app'),
          onConfirmLogoutCallback: (_) async {},
        );
        await tester.pumpAndSettle();

        expect(verifier.calls, 2);
        expect(find.text('Yes'), findsOneWidget);
      },
    );
  });
}
