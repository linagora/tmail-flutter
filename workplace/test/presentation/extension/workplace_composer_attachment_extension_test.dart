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

// Returns responses from a pre-defined queue, one per HTTP request.
// Queue items are either a Map (returned as JSON) or _Fail (throws DioException).
class _SequentialAdapter implements HttpClientAdapter {
  final List<dynamic> _queue;
  int _index = 0;

  _SequentialAdapter(this._queue);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    final item = _queue[_index++];
    if (item is _Fail) {
      throw DioException(requestOptions: options, message: 'Network error');
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

// Returns queued responses like _SequentialAdapter, but also records each
// request body so a test can assert on the outgoing JSON shape.
class _CapturingAdapter implements HttpClientAdapter {
  final List<dynamic> _queue;
  final List<dynamic> capturedBodies = [];
  int _index = 0;

  _CapturingAdapter(this._queue);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    capturedBodies.add(options.data);
    final item = _queue[_index++];
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
  num? maxAttachmentSizeBytes,
  num? remainingAttachmentCapacityBytes,
  OnDrivePickStateChanged? onPickState,
  ValueGetter<bool>? uploadFromUrlSupported,
}) =>
    WorkplaceComposerAttachmentExtension(
      workplaceUri: notifier,
      uploadFromUrlSupported: uploadFromUrlSupported ?? () => true,
      oidcTokenGetter: () => oidcToken,
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
        onPickState: (id, state) {
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
        onPickState: (id, state) {
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
      final adapter = _CapturingAdapter([_tokenResponse, _intentResponse]);
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

      // `_buildIntentRequest` doesn't fully explicitToJson-serialize nested
      // request objects (only WorkplaceFilePickerConfigRequest does), so the
      // captured body still holds the typed request graph at this depth.
      final intentBody = adapter.capturedBodies[1] as Map<String, dynamic>;
      final requestData = intentBody['data'] as WorkplaceIntentDataRequest;
      final downloadLink = requestData.attributes.data.downloadLink;
      expect(downloadLink!.maxFileSize, equals(5000));
      expect(downloadLink.availableSize, equals(5000));
    });
  });
}
