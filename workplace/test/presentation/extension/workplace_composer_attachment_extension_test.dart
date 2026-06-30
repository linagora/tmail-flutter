import 'dart:convert';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/workplace_dio.dart';
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
  OnDrivePickStateChanged? onPickState,
}) =>
    WorkplaceComposerAttachmentExtension(
      workplaceUri: notifier,
      oidcTokenGetter: () => oidcToken,
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
        home: Builder(
          builder: (ctx) => ext.buildContextMenuTile(
            ctx,
            composerId: _composerId,
            imagePaths: imagePaths,
            label: _label,
          ),
        ),
      ));

      expect(find.byType(DriveAttachmentContextMenuTile), findsNothing);
    });

    testWidgets('returns DriveAttachmentContextMenuTile when workplaceUri is set', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              composerId: _composerId,
              imagePaths: imagePaths,
              label: _label,
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
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              composerId: _composerId,
              imagePaths: imagePaths,
              label: _label,
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
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              composerId: _composerId,
              imagePaths: imagePaths,
              label: _label,
            ),
          ),
        ),
      ));

      final tile = tester.widget<DriveAttachmentContextMenuTile>(
        find.byType(DriveAttachmentContextMenuTile),
      );
      expect(tile.label, equals(_label));
    });

    testWidgets('onPickCallback is null when onPickState is not provided', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, onPickState: null);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              composerId: _composerId,
              imagePaths: imagePaths,
              label: _label,
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
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ext.buildContextMenuTile(
              ctx,
              composerId: _composerId,
              imagePaths: imagePaths,
              label: _label,
            ),
          ),
        ),
      ));

      final tile = tester.widget<DriveAttachmentContextMenuTile>(
        find.byType(DriveAttachmentContextMenuTile),
      );
      final fakeState = DrivePickFailure(Exception('test'));
      tile.onPickCallback!(fakeState);

      expect(receivedId, equals(_composerId));
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
          .onFetchIntent;
    }

    testWidgets('throws StateError when oidcTokenGetter returns null', (tester) async {
      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier, oidcToken: null);
      final callback = await extractCallback(tester, ext);

      await expectLater(
        callback(addAsLinkTitle: 'Link', addAsAttachmentTitle: 'Attachment'),
        throwsA(isA<StateError>().having(
          (e) => e.message, 'message', contains('OIDC token'),
        )),
      );
    });

    testWidgets('throws StateError when token exchange fails', (tester) async {
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(addAsLinkTitle: 'Link', addAsAttachmentTitle: 'Attachment'),
          throwsA(isA<StateError>().having(
            (e) => e.message, 'message', contains('Drive access token exchange failed'),
          )),
        );
      });
    });

    testWidgets('returns null when intent creation fails after successful token exchange', (tester) async {
      WorkplaceDio.setInstance(
        Dio()
          ..httpClientAdapter = _SequentialAdapter([_tokenResponse, _fail]),
      );

      final notifier = ValueNotifier<Uri?>(_platformUri);
      final ext = _makeExtension(notifier);
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(addAsLinkTitle: 'Link', addAsAttachmentTitle: 'Attachment'),
      );
      expect(result, isNull);
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
        () => callback(addAsLinkTitle: 'Link', addAsAttachmentTitle: 'Attachment'),
      );
      expect(result, isNotNull);
      expect(result!.intentId, equals('intent-xyz'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });
  });
}
