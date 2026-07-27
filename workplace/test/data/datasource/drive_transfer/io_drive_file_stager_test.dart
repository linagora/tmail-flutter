import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy_factory_mobile.dart';
import 'package:workplace/data/datasource/drive_transfer/io_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getTemporaryPath() async => path;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  static const _chunkSize = 4;

  final List<int> bytes;
  final Map<String, List<String>>? headersOverride;
  RequestOptions? lastRequestOptions;

  _FakeHttpClientAdapter(this.bytes, {this.headersOverride});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    final controller = StreamController<Uint8List>();
    unawaited(() async {
      for (var i = 0; i < bytes.length; i += _chunkSize) {
        final end = (i + _chunkSize).clamp(0, bytes.length);
        controller.add(Uint8List.fromList(bytes.sublist(i, end)));
      }
      await controller.close();
    }());
    return ResponseBody(
      controller.stream,
      200,
      headers: headersOverride ??
          {
            'content-length': ['${bytes.length}']
          },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Emits one chunk then never adds more data and never closes — used to
/// prove cancellation resolves the transfer even when the stream stalls.
class _StallingHttpClientAdapter implements HttpClientAdapter {
  final StreamController<Uint8List> controller = StreamController<Uint8List>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    controller.add(Uint8List.fromList([1, 2, 3, 4]));
    return ResponseBody(controller.stream, 200, headers: {
      'content-length': ['999']
    });
  }

  @override
  void close({bool force = false}) {}
}

const _unset = Object();

void main() {
  late Directory tempDir;
  late Dio originalDio;
  late PathProviderPlatform originalPathProviderPlatform;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('io_drive_file_stager_test');
    originalPathProviderPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    originalDio = WorkplaceDio.instance;
  });

  tearDown(() async {
    WorkplaceDio.setInstance(originalDio);
    PathProviderPlatform.instance = originalPathProviderPlatform;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  DriveDocument buildDoc({Object? downloadLink = _unset, int size = 8}) =>
      DriveDocument(
        id: 'doc-1',
        name: 'file.bin',
        size: size,
        mimeType: 'application/octet-stream',
        downloadLink: identical(downloadLink, _unset)
            ? Uri.parse('https://drive.example/file')
            : downloadLink as Uri?,
      );

  test('streams chunks to a temp file and reports cumulative progress',
      () async {
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes);
    WorkplaceDio.setInstance(dio);

    final received = <int>[];
    final staged = await IoDriveFileStager().stage(
      doc: buildDoc(),
      onDownloadProgress: (r, t) => received.add(r),
      cancelToken: CancelToken(),
    );

    expect(staged, isA<FileBackedStagedFile>());
    final filePath = (staged as FileBackedStagedFile).filePath;
    final writtenBytes = await File(filePath).readAsBytes();
    expect(writtenBytes, bytes);
    expect(received.last, bytes.length);

    await staged.dispose();
    expect(await File(filePath).exists(), isFalse);
  });

  test('dispose() is idempotent when called twice', () async {
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes);
    WorkplaceDio.setInstance(dio);

    final staged = await IoDriveFileStager().stage(
      doc: buildDoc(),
      onDownloadProgress: (_, __) {},
      cancelToken: CancelToken(),
    );

    await staged.dispose();
    await staged.dispose();
  });

  test('deletes the temp file on transfer failure', () async {
    final dio = Dio()..httpClientAdapter = _ThrowingHttpClientAdapter();
    WorkplaceDio.setInstance(dio);

    await expectLater(
      IoDriveFileStager().stage(
        doc: buildDoc(),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(anything),
    );
    expect(tempDir.listSync(), isEmpty);
  });

  test(
      'closes and deletes the temp file when the stream errors after it was created',
      () async {
    final dio = Dio()
      ..httpClientAdapter = _FailingMidStreamHttpClientAdapter();
    WorkplaceDio.setInstance(dio);

    await expectLater(
      IoDriveFileStager().stage(
        doc: buildDoc(),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(anything),
    );

    final leftoverFiles = tempDir.listSync();
    expect(leftoverFiles, isEmpty);
  });

  test('downloadLink == null throws DriveDownloadNullAttachmentException',
      () async {
    expect(
      () => IoDriveFileStager().stage(
        doc: buildDoc(downloadLink: null),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadNullAttachmentException>()),
    );
  });

  test('missing content-length falls back to document.size', () async {
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()
      ..httpClientAdapter =
          _FakeHttpClientAdapter(bytes, headersOverride: const {});
    WorkplaceDio.setInstance(dio);

    final totals = <int>[];
    await IoDriveFileStager().stage(
      doc: buildDoc(size: 8),
      onDownloadProgress: (r, t) => totals.add(t),
      cancelToken: CancelToken(),
    );

    expect(totals, everyElement(8));
  });

  test('invalid content-length falls back to document.size', () async {
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()
      ..httpClientAdapter = _FakeHttpClientAdapter(bytes, headersOverride: {
        'content-length': ['not-a-number']
      });
    WorkplaceDio.setInstance(dio);

    final totals = <int>[];
    await IoDriveFileStager().stage(
      doc: buildDoc(size: 8),
      onDownloadProgress: (r, t) => totals.add(t),
      cancelToken: CancelToken(),
    );

    expect(totals, everyElement(8));
  });

  test('forwards URI, ResponseType.stream, receive timeout and cancel token',
      () async {
    final adapter = _FakeHttpClientAdapter(const [1, 2, 3, 4]);
    final dio = Dio()..httpClientAdapter = adapter;
    final cancelToken = CancelToken();
    final link = Uri.parse('https://drive.example/other-file');

    await IoDriveFileStager(dio: dio).stage(
      doc: buildDoc(downloadLink: link),
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    final requestOptions = adapter.lastRequestOptions!;
    expect(requestOptions.uri, link);
    expect(requestOptions.responseType, ResponseType.stream);
    expect(requestOptions.receiveTimeout, driveTransferReceiveTimeout);
    expect(requestOptions.cancelToken, cancelToken);
  });

  test(
      'cancelling after the first chunk resolves even when the stream never sends more events',
      () async {
    final adapter = _StallingHttpClientAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    WorkplaceDio.setInstance(dio);
    final cancelToken = CancelToken();

    final future = IoDriveFileStager(dio: dio).stage(
      doc: buildDoc(),
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    // Let the first chunk land, then cancel — the fake never emits another
    // event or closes, so only `cancelToken.whenCancel` can unblock this.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    cancelToken.cancel();

    await expectLater(
      future,
      throwsA(isA<DioException>().having(
        (e) => e.type,
        'type',
        DioExceptionType.cancel,
      )),
    );
    expect(tempDir.listSync(), isEmpty);
    await adapter.controller.close();
  });

  test('fails and cleans up when the temp directory does not exist',
      () async {
    PathProviderPlatform.instance =
        _FakePathProviderPlatform('${tempDir.path}/missing-parent');
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes);
    WorkplaceDio.setInstance(dio);

    await expectLater(
      IoDriveFileStager(dio: dio).stage(
        doc: buildDoc(),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<FileSystemException>()),
    );
  });

  group('IoDriveTransferStrategy', () {
    test('defaults to an IoDriveFileStager', () {
      final strategy = IoDriveTransferStrategy();
      expect(strategy.stager, isA<IoDriveFileStager>());
    });

    test('uses the injected stager when provided', () {
      final customStager = _NoopDriveFileStager();
      final strategy = IoDriveTransferStrategy(stager: customStager);
      expect(strategy.stager, same(customStager));
    });

    test('opfsUploader is always null', () {
      expect(IoDriveTransferStrategy().opfsUploader, isNull);
    });
  });

  group('DriveTransferStrategyFactory', () {
    test('creates an IoDriveTransferStrategy', () {
      expect(DriveTransferStrategyFactory.create(), isA<IoDriveTransferStrategy>());
    });
  });
}

class _NoopDriveFileStager implements DriveFileStager {
  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required void Function(int received, int total) onDownloadProgress,
    required CancelToken cancelToken,
  }) =>
      throw UnimplementedError();
}

class _ThrowingHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(requestOptions: options, error: 'boom');
  }

  @override
  void close({bool force = false}) {}
}

/// Returns a successful response — the temp file is created and opened —
/// then errors mid-stream, exercising the post-creation cleanup path.
class _FailingMidStreamHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final controller = StreamController<Uint8List>();
    unawaited(() async {
      controller.add(Uint8List.fromList([1, 2, 3, 4]));
      await Future<void>.delayed(Duration.zero);
      controller.addError(DioException(requestOptions: options, error: 'boom'));
      await controller.close();
    }());
    return ResponseBody(
      controller.stream,
      200,
      headers: {
        'content-length': ['8']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
