import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
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
    test('stage() delegates to the injected stager, passing args through',
        () async {
      final stager = _RecordingDriveFileStager();
      final strategy = BufferedWebDriveTransferStrategy(
        uploader: _unreachableUploader,
        stager: stager,
      );
      final doc = _buildDoc(downloadLink: _defaultDownloadLink);
      final cancelToken = CancelToken();
      void onProgress(int r, int t) {}

      final staged = await strategy.stage(
        doc: doc,
        onDownloadProgress: onProgress,
        cancelToken: cancelToken,
      );

      expect(staged, same(stager.result));
      expect(stager.doc, same(doc));
      expect(stager.onDownloadProgress, same(onProgress));
      expect(stager.cancelToken, same(cancelToken));
    });

    test('stage() defaults to a BufferedWebDriveFileStager', () async {
      WorkplaceDio.setInstance(
          Dio()..httpClientAdapter = _FakeHttpClientAdapter([1, 2, 3]));

      final staged =
          await BufferedWebDriveTransferStrategy(uploader: _unreachableUploader)
              .stage(
        doc: _buildDoc(downloadLink: _defaultDownloadLink),
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      );

      expect(staged, isA<BytesStagedFile>());
    });

    test('upload() delegates to the injected uploader, ignoring authHeader',
        () async {
      final uploader = _RecordingStagedFileUploader();
      final strategy = BufferedWebDriveTransferStrategy(
        uploader: uploader.call,
        stager: _RecordingDriveFileStager(),
      );
      final staged = _bytesStagedFile();
      final uploadUri = Uri.parse('https://jmap.example/upload');
      final cancelToken = CancelToken();
      void onProgress(int r, int t) {}

      final attachment = await strategy.upload(
        staged: staged,
        uploadUri: uploadUri,
        authHeader: 'Bearer token',
        onUploadProgress: onProgress,
        cancelToken: cancelToken,
      );

      expect(attachment, same(uploader.result));
      expect(uploader.staged, same(staged));
      expect(uploader.uploadUri, uploadUri);
      expect(uploader.onUploadProgress, same(onProgress));
      expect(uploader.cancelToken, same(cancelToken));
    });
  });
}

BytesStagedFile _bytesStagedFile() => BytesStagedFile(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'file.bin',
      fileSize: 3,
    );

Future<Attachment> _unreachableUploader({
  required StagedDriveFile staged,
  required Uri uploadUri,
  required OnFileProcessedProgress onUploadProgress,
  required CancelToken cancelToken,
}) =>
    throw UnimplementedError();

class _RecordingDriveFileStager implements DriveFileStager {
  final StagedDriveFile result = _bytesStagedFile();

  DriveDocument? doc;
  OnFileProcessedProgress? onDownloadProgress;
  CancelToken? cancelToken;

  @override
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    this.doc = doc;
    this.onDownloadProgress = onDownloadProgress;
    this.cancelToken = cancelToken;
    return result;
  }
}

class _RecordingStagedFileUploader {
  final Attachment result = Attachment(name: 'file.bin');

  StagedDriveFile? staged;
  Uri? uploadUri;
  OnFileProcessedProgress? onUploadProgress;
  CancelToken? cancelToken;

  Future<Attachment> call({
    required StagedDriveFile staged,
    required Uri uploadUri,
    required OnFileProcessedProgress onUploadProgress,
    required CancelToken cancelToken,
  }) async {
    this.staged = staged;
    this.uploadUri = uploadUri;
    this.onUploadProgress = onUploadProgress;
    this.cancelToken = cancelToken;
    return result;
  }
}
