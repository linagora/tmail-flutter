import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<int> bytes;
  RequestOptions? lastRequestOptions;

  _FakeHttpClientAdapter(this.bytes);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    options.onReceiveProgress?.call(bytes.length, bytes.length);
    return ResponseBody.fromBytes(bytes, 200);
  }

  @override
  void close({bool force = false}) {}
}

class _FailingHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CancellingHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await cancelFuture;
    throw DioException(requestOptions: options, type: DioExceptionType.cancel);
  }

  @override
  void close({bool force = false}) {}
}

final _defaultDownloadLink = Uri.parse('https://drive.example/file');

DriveDocument _buildDoc({
  required Uri? downloadLink,
  String mimeType = 'application/octet-stream',
  int size = 16,
}) =>
    DriveDocument(
      id: 'doc-1',
      name: 'file.bin',
      size: size,
      mimeType: mimeType,
      downloadLink: downloadLink,
    );

void main() {
  late Dio originalDio;

  setUp(() => originalDio = WorkplaceDio.instance);
  tearDown(() => WorkplaceDio.setInstance(originalDio));

  test('buffers the full response and forwards onReceiveProgress', () async {
    final bytes = List<int>.generate(16, (i) => i);
    WorkplaceDio.setInstance(Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes));

    final progress = <List<int>>[];
    final staged = await BufferedWebDriveFileStager().stage(
      doc: _buildDoc(downloadLink: _defaultDownloadLink),
      onDownloadProgress: (r, t) => progress.add([r, t]),
      cancelToken: CancelToken(),
    );

    expect(staged, isA<BytesStagedFile>());
    expect((staged as BytesStagedFile).bytes, bytes);
    expect(progress, isNotEmpty);
    expect(progress.last.first, bytes.length);

    await staged.dispose();
  });

  test('preserves fileName, mimeType and fileSize metadata', () async {
    final bytes = List<int>.generate(8, (i) => i);
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes);

    final staged = await BufferedWebDriveFileStager(dio: dio).stage(
      doc: _buildDoc(downloadLink: _defaultDownloadLink, mimeType: 'image/png'),
      onDownloadProgress: (_, __) {},
      cancelToken: CancelToken(),
    ) as BytesStagedFile;

    expect(staged.fileName, 'file.bin');
    expect(staged.mimeType, 'image/png');
    expect(staged.fileSize, bytes.length);
  });

  test('empty response yields a staged file with fileSize 0', () async {
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(const []);

    final staged = await BufferedWebDriveFileStager(dio: dio).stage(
      doc: _buildDoc(downloadLink: _defaultDownloadLink),
      onDownloadProgress: (_, __) {},
      cancelToken: CancelToken(),
    ) as BytesStagedFile;

    expect(staged.bytes, isEmpty);
    expect(staged.fileSize, 0);
  });

  test('forwards URI, ResponseType.bytes, receive timeout and cancel token', () async {
    final adapter = _FakeHttpClientAdapter(const [1, 2, 3]);
    final dio = Dio()..httpClientAdapter = adapter;
    final cancelToken = CancelToken();
    final link = Uri.parse('https://drive.example/other-file');

    await BufferedWebDriveFileStager(dio: dio).stage(
      doc: _buildDoc(downloadLink: link),
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );

    final requestOptions = adapter.lastRequestOptions!;
    expect(requestOptions.uri, link);
    expect(requestOptions.responseType, ResponseType.bytes);
    expect(requestOptions.receiveTimeout, driveTransferReceiveTimeout);
    expect(requestOptions.cancelToken, cancelToken);
  });

  test('downloadLink == null throws DriveDownloadNullAttachmentException', () async {
    expect(
      () => BufferedWebDriveFileStager().stage(
        doc: _buildDoc(downloadLink: null),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadNullAttachmentException>()),
    );
  });

  test('Dio network failures propagate as DioException', () async {
    final dio = Dio()..httpClientAdapter = _FailingHttpClientAdapter();

    expect(
      () => BufferedWebDriveFileStager(dio: dio).stage(
        doc: _buildDoc(downloadLink: _defaultDownloadLink),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DioException>()),
    );
  });

  test('isReleaseMode true and http downloadLink throws DriveDownloadInsecureLinkException', () async {
    final insecureLink = Uri.parse('http://drive.example/file');

    expect(
      () => BufferedWebDriveFileStager(isReleaseMode: true).stage(
        doc: _buildDoc(downloadLink: insecureLink),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(isA<DriveDownloadInsecureLinkException>()),
    );
  });

  test('isReleaseMode true and https downloadLink succeeds', () async {
    final bytes = List<int>.generate(4, (i) => i);
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes);

    final staged = await BufferedWebDriveFileStager(
      dio: dio,
      isReleaseMode: true,
    ).stage(
      doc: _buildDoc(downloadLink: _defaultDownloadLink),
      onDownloadProgress: (_, __) {},
      cancelToken: CancelToken(),
    );

    expect(staged, isA<BytesStagedFile>());
  });

  test('cancellation propagates as a DioException of type cancel', () async {
    final dio = Dio()..httpClientAdapter = _CancellingHttpClientAdapter();
    final cancelToken = CancelToken();

    final future = BufferedWebDriveFileStager(dio: dio).stage(
      doc: _buildDoc(downloadLink: _defaultDownloadLink),
      onDownloadProgress: (_, __) {},
      cancelToken: cancelToken,
    );
    cancelToken.cancel();

    await expectLater(
      future,
      throwsA(isA<DioException>().having(
        (e) => e.type,
        'type',
        DioExceptionType.cancel,
      )),
    );
  });

  group('BufferedWebDriveTransferStrategy', () {
    test('defaults to a BufferedWebDriveFileStager', () {
      final strategy = BufferedWebDriveTransferStrategy();
      expect(strategy.stager, isA<BufferedWebDriveFileStager>());
    });

    test('uses the injected stager when provided', () {
      final customStager = _NoopDriveFileStager();
      final strategy = BufferedWebDriveTransferStrategy(stager: customStager);
      expect(strategy.stager, same(customStager));
    });

    test('opfsUploader is always null', () {
      expect(BufferedWebDriveTransferStrategy().opfsUploader, isNull);
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
