import 'dart:convert';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';
import 'package:workplace/presentation/widget/drive_attachment_context_menu_tile.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

// Sentinel used by _SequentialAdapter to throw DioException on a given call.
class _Fail {
  const _Fail();
}

const _fail = _Fail();

// Sentinel used by _SequentialAdapter to throw a DioException with a status.
class _FailStatus {
  final int statusCode;

  const _FailStatus(this.statusCode);
}

const _fail401 = _FailStatus(401);
const _fail400 = _FailStatus(400);

// Returns responses from a pre-defined queue, one per HTTP request, and
// records each request body so a test can assert on the outgoing JSON.
// Queue items are a Map (returned as JSON), _Fail (network error, no
// response), or _FailStatus (a status response, e.g. a stale OIDC id token).
class _SequentialAdapter implements HttpClientAdapter {
  final List<dynamic> _queue;
  final List<dynamic> capturedBodies = [];
  int _index = 0;

  _SequentialAdapter(this._queue);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    capturedBodies.add(options.data);
    final item = _queue[_index++];
    if (item is _Fail) {
      throw DioException(requestOptions: options, message: 'Network error');
    }
    if (item is _FailStatus) {
      throw DioException(
        requestOptions: options,
        response: Response(statusCode: item.statusCode, requestOptions: options),
        type: DioExceptionType.badResponse,
      );
    }
    return ResponseBody.fromString(
      jsonEncode(item),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// Always throws DioException to simulate a network failure.
class _ErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async =>
      throw DioException(requestOptions: options, message: 'Network error');

  @override
  void close({bool force = false}) {}
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

final _platformUri = Uri.parse('https://platform.example.com');
const _composerId = 'composer-1';
const _label = 'Attach from Drive';

final _tokenResponse = {'access_token': 'drive-access-token'};
final _intentResponse = {
  'data': {
    'id': 'intent-xyz',
    'attributes': {
      'action': 'PICK',
      'type': 'files',
      'permissions': ['GET'],
      'services': [
        {'href': 'https://drive.example.com/pick'},
      ],
    },
  },
};

// ── Factory ───────────────────────────────────────────────────────────────────

WorkplaceComposerAttachmentExtension _makeExtension(
  ValueListenable<Uri?> notifier, {
  String? oidcToken = 'oidc-token',
  String? Function()? oidcTokenGetter,
  num? maxAttachmentSizeBytes,
  num? remainingAttachmentCapacityBytes,
  OnDrivePickStateChanged? onPickState,
  ValueGetter<bool>? uploadFromUrlSupported,
  OidcRefreshTrigger? oidcRefreshTrigger,
}) =>
    WorkplaceComposerAttachmentExtension(
      workplaceUri: notifier,
      uploadFromUrlSupported: uploadFromUrlSupported ?? () => true,
      oidcTokenGetter: oidcTokenGetter ?? () => oidcToken,
      oidcRefreshTrigger: oidcRefreshTrigger ?? () async => null,
      maxAttachmentSizeBytesGetter: () => maxAttachmentSizeBytes,
      remainingAttachmentCapacityBytesGetter: (_) => remainingAttachmentCapacityBytes,
      onPickState: onPickState,
    );

void main() {
  final imagePaths = ImagePaths();

  // ── Group 1: buildToolbarButton ───────────────────────────────────────────

  group('WorkplaceComposerAttachmentExtension::buildToolbarButton::', () {
    testWidgets('returns SizedBox.shrink when workplaceUri is null', (tester) async {
      final notifier = ValueNotifier<Uri?>(null);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));

      expect(find.byType(DriveAttachmentPickerButton), findsNothing);
    });

    testWidgets('returns DriveAttachmentPickerButton when workplaceUri is set', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));

      expect(find.byType(DriveAttachmentPickerButton), findsOneWidget);
    });

    testWidgets('rebuilds to show button when uri changes from null to value', (tester) async {
      final notifier = ValueNotifier<Uri?>(null);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));
      expect(find.byType(DriveAttachmentPickerButton), findsNothing);

      notifier.value = _platformUri;
      await tester.pump();

      expect(find.byType(DriveAttachmentPickerButton), findsOneWidget);
    });

    testWidgets('rebuilds to hide button when uri changes from value to null', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));
      expect(find.byType(DriveAttachmentPickerButton), findsOneWidget);

      notifier.value = null;
      await tester.pump();

      expect(find.byType(DriveAttachmentPickerButton), findsNothing);
    });

    testWidgets('onPickCallback is null when onPickState is not provided', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, onPickState: null);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));

      final button = tester.widget<DriveAttachmentPickerButton>(
        find.byType(DriveAttachmentPickerButton),
      );
      expect(button.onPickCallback, isNull);
    });

    testWidgets('onPickCallback forwards composerId and state to onPickState', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      String? receivedId;
      DrivePickState? receivedState;

      final ext = _makeExtension(
        notifier,
        onPickState: (id, state) async {
          receivedId = id;
          receivedState = state;
        },
      );

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));

      final button = tester.widget<DriveAttachmentPickerButton>(
        find.byType(DriveAttachmentPickerButton),
      );
      final fakeState = DrivePickResult(const []);
      button.onPickCallback!(fakeState);

      expect(receivedId, equals(_composerId));
      expect(receivedState, equals(fakeState));
    });
  });

  // ── Group 2: buildContextMenuTile ─────────────────────────────────────────

  group('WorkplaceComposerAttachmentExtension::buildContextMenuTile::', () {
    testWidgets('returns SizedBox.shrink when workplaceUri is null', (tester) async {
      final notifier = ValueNotifier<Uri?>(null);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (ctx) => ext.buildContextMenuTile(
            ctx,
            imagePaths: imagePaths,
          ),
        ),
      ));

      expect(find.byType(DriveAttachmentContextMenuTile), findsNothing);
    });

    testWidgets('returns DriveAttachmentContextMenuTile when workplaceUri is set', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ));

      expect(find.byType(DriveAttachmentContextMenuTile), findsOneWidget);
    });

    testWidgets('rebuilds to show tile when uri changes from null to value', (tester) async {
      final notifier = ValueNotifier<Uri?>(null);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ));
      expect(find.byType(DriveAttachmentContextMenuTile), findsNothing);

      notifier.value = _platformUri;
      await tester.pump();

      expect(find.byType(DriveAttachmentContextMenuTile), findsOneWidget);
    });

    testWidgets('passes label to DriveAttachmentContextMenuTile', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ));

      expect(find.text(_label), findsOneWidget);
    });

    testWidgets('onPickCallback is null when onPickState is not provided', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, onPickState: null);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ));

      final tile = tester.widget<DriveAttachmentContextMenuTile>(
        find.byType(DriveAttachmentContextMenuTile),
      );
      expect(tile.onPickCallback, isNull);
    });

    testWidgets('onPickCallback forwards composerId and state to onPickState', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      String? receivedId;
      DrivePickState? receivedState;

      final ext = _makeExtension(
        notifier,
        onPickState: (id, state) async {
          receivedId = id;
          receivedState = state;
        },
      );

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              imagePaths: imagePaths,
            ),
          ),
        ),
      ));

      final tile = tester.widget<DriveAttachmentContextMenuTile>(
        find.byType(DriveAttachmentContextMenuTile),
      );
      final fakeState = DrivePickFailure(Exception('test'));
      tile.onPickCallback!(fakeState);

      expect(receivedId, isNull);
      expect(receivedState, equals(fakeState));
    });
  });

  // ── Group 3: _fetchIntent network flow ────────────────────────────────────
  //
  // The private _fetchIntent is accessed indirectly via the onFetchIntent
  // callback injected into DriveAttachmentPickerButton.

  group('WorkplaceComposerAttachmentExtension::_fetchIntent::', () {
    late Dio originalDio;

    setUp(() => originalDio = WorkplaceDio.instance);
    tearDown(() => WorkplaceDio.setInstance(originalDio));

    Future<FetchDriveIntentCallback> extractCallback(
      WidgetTester tester,
      WorkplaceComposerAttachmentExtension ext,
    ) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => ext.buildToolbarButton(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
          ),
        ),
      ));
      return tester
          .widget<DriveAttachmentPickerButton>(
            find.byType(DriveAttachmentPickerButton),
          )
          .session
          .onFetchIntent;
    }

    testWidgets('throws StateError when oidcTokenGetter returns null', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, oidcToken: null);
      final callback = await extractCallback(tester, ext);

      await expectLater(
        callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message, 'message', contains('OIDC token'),
        )),
      );
    });

    testWidgets('throws when token exchange fails', (tester) async {
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
          throwsA(isA<DioException>()),
        );
      });
    });

    testWidgets('throws when intent creation fails after successful token exchange', (tester) async {
      WorkplaceDio.setInstance(
        Dio()
          ..httpClientAdapter = _SequentialAdapter([_tokenResponse, _fail]),
      );

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
          throwsA(isA<DioException>()),
        );
      });
    });

    testWidgets('returns WorkplaceIntent when token exchange and intent creation both succeed', (tester) async {
      WorkplaceDio.setInstance(
        Dio()
          ..httpClientAdapter = _SequentialAdapter([_tokenResponse, _intentResponse]),
      );

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
      );
      expect(result, isNotNull);
      expect(result!.intentId, equals('intent-xyz'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });

    testWidgets('forwards downloadLink maxFileSize/availableSize from filePickerConfig into the request', (tester) async {
      final adapter = _SequentialAdapter([_tokenResponse, _intentResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, maxAttachmentSizeBytes: 5000);
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(
        () => callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(
              label: 'Attachment',
              maxFileSize: 5000,
              availableSize: 5000,
            ),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
      );

      final intentBody = adapter.capturedBodies[1] as Map<String, dynamic>;
      final requestData = intentBody['data'] as Map<String, dynamic>;
      final attributes = requestData['attributes'] as Map<String, dynamic>;
      final filePickerData = attributes['data'] as Map<String, dynamic>;
      final downloadLink = filePickerData['downloadLink'] as Map<String, dynamic>;
      expect(downloadLink['maxFileSize'], equals(5000));
      expect(downloadLink['availableSize'], equals(5000));
    });

    testWidgets('retries once via oidcRefreshTrigger after a 400, then succeeds', (tester) async {
      // RFC 8693's invalid_grant answer for a stale subject_token.
      final adapter = _SequentialAdapter([_fail400, _tokenResponse, _intentResponse]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      var refreshCallCount = 0;
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        oidcRefreshTrigger: () async {
          refreshCallCount++;
          return 'refreshed-oidc-token';
        },
      );
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
      );

      expect(refreshCallCount, equals(1));
      expect(result!.intentId, equals('intent-xyz'));
      expect(adapter.capturedBodies[1]['id_token'], equals('refreshed-oidc-token'));
    });

    testWidgets('retries once via oidcRefreshTrigger after a 401, then succeeds', (tester) async {
      final adapter = _SequentialAdapter([
        _fail401, // stale token exchange → 401
        _tokenResponse, // retry with refreshed token → succeeds
        _intentResponse,
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      var refreshCallCount = 0;
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        oidcRefreshTrigger: () async {
          refreshCallCount++;
          return 'refreshed-oidc-token';
        },
      );
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(
          filePickerConfig: const WorkplaceFilePickerConfigRequest(
            sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
            downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
            theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
          ),
        ),
      );

      expect(refreshCallCount, equals(1));
      expect(result, isNotNull);
      expect(result!.intentId, equals('intent-xyz'));
      expect(adapter.capturedBodies[0]['id_token'], equals('oidc-token'));
      expect(adapter.capturedBodies[1]['id_token'], equals('refreshed-oidc-token'));
    });

    testWidgets('does not retry twice when the refreshed token also gets a 401', (tester) async {
      WorkplaceDio.setInstance(
        Dio()
          ..httpClientAdapter = _SequentialAdapter([_fail401, _fail401]),
      );

      var refreshCallCount = 0;
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        oidcRefreshTrigger: () async {
          refreshCallCount++;
          return 'refreshed-oidc-token';
        },
      );
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(
            filePickerConfig: const WorkplaceFilePickerConfigRequest(
              sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
              downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
              theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
            ),
          ),
          throwsA(isA<DioException>()),
        );
      });

      // Called once for the first 401, not again after the retry also fails.
      expect(refreshCallCount, equals(1));
    });

    testWidgets('does not retry when the refresh keeps the id token that just 401ed', (tester) async {
      final adapter = _SequentialAdapter([_fail401]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      var refreshCallCount = 0;
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        // The IdP omitted id_token, so the interceptor kept the current one.
        oidcRefreshTrigger: () async {
          refreshCallCount++;
          return 'oidc-token';
        },
      );
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(
            filePickerConfig: const WorkplaceFilePickerConfigRequest(
              sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
              downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
              theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
            ),
          ),
          throwsA(isA<DioException>()),
        );
      });

      expect(refreshCallCount, equals(1));
      // No second exchange: the token that just failed is not re-sent.
      expect(adapter.capturedBodies, hasLength(1));
    });
    testWidgets('propagates the oidcRefreshTrigger failure after a 401 with no second exchange', (tester) async {
      final adapter = _SequentialAdapter([_fail401]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      // Stands in for the app's RefreshTokenFailedException: must reach the
      // picker failure untouched so the app can route it to logout.
      final rejection = StateError('refresh rejected by the server');
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        oidcRefreshTrigger: () async => throw rejection,
      );
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(
            filePickerConfig: const WorkplaceFilePickerConfigRequest(
              sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
              downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
              theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
            ),
          ),
          throwsA(same(rejection)),
        );
      });

      expect(adapter.capturedBodies, hasLength(1));
    });
    testWidgets('reuses the already-refreshed token when a second 401 arrives late, with one refresh', (tester) async {
      final adapter = _SequentialAdapter([
        _fail401, // A: old token → 401
        _tokenResponse, // A: retry with refreshed token
        _intentResponse,
        _fail401, // B: still sent the old token → 401
        _tokenResponse, // B: retry with current token, no refresh
        _intentResponse,
      ]);
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = adapter);

      var refreshCallCount = 0;
      var currentToken = 'old-oidc-token';
      var tokenReads = 0;
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(
        notifier,
        // Reads 1-2: A start + A retry check; read 3: B start (old); read 4: B retry check.
        oidcTokenGetter: () => ++tokenReads <= 3 ? 'old-oidc-token' : currentToken,
        oidcRefreshTrigger: () async {
          refreshCallCount++;
          currentToken = 'refreshed-oidc-token';
          return currentToken;
        },
      );
      final callback = await extractCallback(tester, ext);
      const config = WorkplaceFilePickerConfigRequest(
        sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
        downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
        theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
      );

      final resultA = await tester.runAsync(() => callback(filePickerConfig: config));
      final resultB = await tester.runAsync(() => callback(filePickerConfig: config));

      expect(refreshCallCount, equals(1));
      expect(resultA?.intentId, equals('intent-xyz'));
      expect(resultB?.intentId, equals('intent-xyz'));
      // Bodies: [0] A old, [1] A retry, [2] A intent, [3] B old, [4] B retry, [5] B intent.
      expect(adapter.capturedBodies[0]['id_token'], equals('old-oidc-token'));
      expect(adapter.capturedBodies[1]['id_token'], equals('refreshed-oidc-token'));
      expect(adapter.capturedBodies[3]['id_token'], equals('old-oidc-token'));
      expect(adapter.capturedBodies[4]['id_token'], equals('refreshed-oidc-token'));
    });
  });
}
