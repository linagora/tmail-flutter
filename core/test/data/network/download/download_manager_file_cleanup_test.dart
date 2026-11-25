@TestOn('vm')

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/download/download_client.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/domain/exceptions/download_file_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A download that never settles would hang the caller's loading dialog, so every call is bounded.
  const settleTimeout = Duration(seconds: 5);
  const fileName = 'report.pdf';

  late Directory temporaryRoot;

  setUp(() {
    temporaryRoot = Directory.systemTemp.createTempSync('download_manager_test_');
    addTearDown(() => temporaryRoot.deleteSync(recursive: true));
  });

  ResponseBody bodyThatFailsMidStream() => ResponseBody(
    Stream<Uint8List>.multi((controller) {
      controller.add(Uint8List.fromList([1, 2, 3]));
      controller.addError(Exception('connection reset'));
      controller.close();
    }),
    200,
  );

  ResponseBody bodyOfBytes(List<int> bytes) => ResponseBody.fromBytes(bytes, 200);

  group('DownloadManager::downloadFile when the staging directory cannot be removed', () {
    test(
      'SHOULD fail with the download error\n'
      'WHEN the response stream fails',
    () async {
      final downloadManager = DownloadManager(_FakeDownloadClient(bodyThatFailsMidStream()));

      final download = downloadManager.downloadFile(
        'https://example.com/download',
        Future.value(_UndeletableStagingRootDirectory(temporaryRoot)),
        fileName,
        'auth',
      );

      await expectLater(
        download.timeout(settleTimeout),
        throwsA(isA<CommonDownloadFileException>()),
      );
    });

    test(
      'SHOULD fail with the write error\n'
      'WHEN writing a chunk to disk fails',
    () async {
      final downloadManager = DownloadManager(_FakeDownloadClient(bodyOfBytes([1, 2, 3])));
      final randomAccessFile = _WriteFailingRandomAccessFile();

      final download = IOOverrides.runZoned(
        () => downloadManager.downloadFile(
          'https://example.com/download',
          Future.value(_UndeletableStagingRootDirectory(temporaryRoot)),
          fileName,
          'auth',
        ),
        createFile: (path) => _FakeFile(path, randomAccessFile),
      );

      await expectLater(
        download.timeout(settleTimeout),
        throwsA(isA<CommonDownloadFileException>()),
      );
    });
  });

  group('DownloadManager::downloadFile when writing a chunk to disk fails', () {
    test(
      'SHOULD close the file it opened\n'
      'WHEN the download fails',
    () async {
      final downloadManager = DownloadManager(_FakeDownloadClient(bodyOfBytes([1, 2, 3])));
      final randomAccessFile = _WriteFailingRandomAccessFile();

      final download = IOOverrides.runZoned(
        () => downloadManager.downloadFile(
          'https://example.com/download',
          Future.value(temporaryRoot),
          fileName,
          'auth',
        ),
        createFile: (path) => _FakeFile(path, randomAccessFile),
      );

      await expectLater(
        download.timeout(settleTimeout),
        throwsA(isA<CommonDownloadFileException>()),
      );
      expect(randomAccessFile.isClosed, isTrue);
    });
  });
}

class _FakeDownloadClient extends Fake implements DownloadClient {
  _FakeDownloadClient(this._responseBody);

  final ResponseBody _responseBody;

  @override
  Future<ResponseBody> downloadFile(String url, String basicAuth, CancelToken? cancelToken) async =>
      _responseBody;
}

/// A real directory whose staging subdirectories exist on disk but refuse to be deleted,
/// as when the app's temporary directory is cleared or becomes read-only mid-download.
class _UndeletableStagingRootDirectory extends Fake implements Directory {
  _UndeletableStagingRootDirectory(this._directory);

  final Directory _directory;

  @override
  String get path => _directory.path;

  @override
  Directory get absolute => this;

  @override
  void createSync({bool recursive = false}) => _directory.createSync(recursive: recursive);

  @override
  Directory createTempSync([String? prefix]) =>
      _UndeletableDirectory(_directory.createTempSync(prefix));
}

class _UndeletableDirectory extends Fake implements Directory {
  _UndeletableDirectory(this._directory);

  final Directory _directory;

  @override
  String get path => _directory.path;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async =>
      throw FileSystemException('Permission denied', path);
}

class _FakeFile extends Fake implements File {
  _FakeFile(this.path, this._randomAccessFile);

  @override
  final String path;

  final RandomAccessFile _randomAccessFile;

  @override
  RandomAccessFile openSync({FileMode mode = FileMode.read}) => _randomAccessFile;
}

/// Fails every write, as on a full disk, and records whether it was closed.
class _WriteFailingRandomAccessFile extends Fake implements RandomAccessFile {
  bool isClosed = false;

  @override
  Future<RandomAccessFile> writeFrom(List<int> buffer, [int start = 0, int? end]) async =>
      throw const FileSystemException('No space left on device');

  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  void closeSync() {
    isClosed = true;
  }
}
