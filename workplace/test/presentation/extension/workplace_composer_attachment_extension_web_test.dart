@TestOn('chrome')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_enums.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/widget/drive_attachment_picker_button.dart';

import '../../test_utils/cozy_bridge_test_helper.dart';

// Queues responses per HTTP request; used only by the bearer-token fallback.
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
    return ResponseBody.fromString(
      jsonEncode(_queue[_index++]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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

final _platformUri = Uri.parse('https://platform.example.com');
final _tokenResponse = {'access_token': 'drive-access-token'};
final _bridgeIntentResponse = {
  'data': {
    'id': 'intent-bridge',
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
final _bearerIntentResponse = {
  'data': {
    'id': 'intent-bearer',
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

WorkplaceComposerAttachmentExtension _makeExtension(ValueListenable<Uri?> notifier) =>
    WorkplaceComposerAttachmentExtension(
      workplaceUri: notifier,
      uploadFromUrlSupported: () => true,
      oidcTokenGetter: () => 'oidc-token',
      maxAttachmentSizeBytesGetter: () => null,
      remainingAttachmentCapacityBytesGetter: (_) => null,
      oidcRefreshTrigger: () => Future.value(null),
    );

const _filePickerConfig = WorkplaceFilePickerConfigRequest(
  sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
  downloadLink: WorkplaceActionConfigRequest(label: 'Attachment'),
  theme: WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light),
);

void main() {
  late Dio originalDio;

  setUp(() => originalDio = WorkplaceDio.instance);
  tearDown(() {
    removeCozyBridge();
    WorkplaceDio.setInstance(originalDio);
  });

  Future<FetchDriveIntentCallback> extractCallback(
    WidgetTester tester,
    WorkplaceComposerAttachmentExtension ext,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => ext.buildToolbarButton(
          ctx,
          composerId: 'composer-1',
          imagePaths: ImagePaths(),
        ),
      ),
    ));
    return tester
        .widget<DriveAttachmentPickerButton>(find.byType(DriveAttachmentPickerButton))
        .session
        .onFetchIntent;
  }

  group('WorkplaceComposerAttachmentExtension::_fetchIntent::CozyBridge fallback::', () {
    testWidgets('returns via the bridge without touching WorkplaceDio when it succeeds', (tester) async {
      installCozyBridge((_) => _bridgeIntentResponse.jsify());
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      final ext = _makeExtension(ValueNotifier<Uri?>(_platformUri));
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(filePickerConfig: _filePickerConfig),
      );

      expect(result!.intentId, equals('intent-bridge'));
    });

    testWidgets('falls back to bearer-token flow when the bridge call throws', (tester) async {
      installCozyBridge((_) => throw StateError('bridge rejected'));
      WorkplaceDio.setInstance(
        Dio()..httpClientAdapter = _SequentialAdapter([_tokenResponse, _bearerIntentResponse]),
      );

      final ext = _makeExtension(ValueNotifier<Uri?>(_platformUri));
      final callback = await extractCallback(tester, ext);

      final result = await tester.runAsync(
        () => callback(filePickerConfig: _filePickerConfig),
      );

      expect(result!.intentId, equals('intent-bearer'));
    });

    testWidgets('propagates the bearer-flow error when both the bridge and the fallback fail', (tester) async {
      installCozyBridge((_) => throw StateError('bridge rejected'));
      WorkplaceDio.setInstance(Dio()..httpClientAdapter = _ErrorAdapter());

      final ext = _makeExtension(ValueNotifier<Uri?>(_platformUri));
      final callback = await extractCallback(tester, ext);

      await tester.runAsync(() async {
        await expectLater(
          callback(filePickerConfig: _filePickerConfig),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
