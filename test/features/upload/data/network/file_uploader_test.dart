import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

void main() {
  Future<HttpServer> startConcurrentUploadServer(List<List<int>> receivedBodies) async {
    final secondRequestStarted = Completer<void>();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = <int>[];
      await for (final chunk in request) {
        body.addAll(chunk);
      }
      receivedBodies.add(body);
      if (receivedBodies.length == 2 && !secondRequestStarted.isCompleted) {
        secondRequestStarted.complete();
      }
      await secondRequestStarted.future.timeout(const Duration(seconds: 30));
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-${receivedBodies.length}',
        'type': 'application/pdf',
        'size': body.length,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }


  Future<HttpServer> startStalledUploadServer({
    required Completer<void> requestReceived,
    required Completer<void> releaseResponse,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      await request.drain<void>();
      if (!requestReceived.isCompleted) {
        requestReceived.complete();
      }
      await releaseResponse.future;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'application/pdf',
        'size': 0,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      if (!releaseResponse.isCompleted) {
        releaseResponse.complete();
      }
      await server.close(force: true);
    });
    return server;
  }

  Future<HttpServer> startRecordingUploadServer(List<List<int>> receivedBodies) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = <int>[];
      await for (final chunk in request) {
        body.addAll(chunk);
      }
      receivedBodies.add(body);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'text/plain',
        'size': body.length,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  Future<Attachment> uploadTextFileFromDisk({
    required String fileName,
    required String content,
    required List<List<int>> receivedBodies,
  }) async {
    final directory = await Directory.systemTemp.createTemp('charset-upload-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    final server = await startRecordingUploadServer(receivedBodies);

    return FileUploader(DioClient(Dio()), FileUtils()).uploadAttachment(
      UploadTaskId('upload-$fileName'),
      FileInfo(
        fileName: fileName,
        fileSize: await file.length(),
        filePath: file.path,
        type: FileUtils.TEXT_PLAIN_MIME_TYPE,
      ),
      Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    ).timeout(const Duration(seconds: 30));
  }

  test('streams local attachment uploads concurrently on the root client', () async {
    final sourceA = <int>[1, 2, 3];
    final sourceB = <int>[4, 5, 6];
    final directory = await Directory.systemTemp.createTemp('root-upload-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final fileA = File('${directory.path}/a.pdf');
    final fileB = File('${directory.path}/b.pdf');
    await fileA.writeAsBytes(sourceA);
    await fileB.writeAsBytes(sourceB);

    final receivedBodies = <List<int>>[];
    final server = await startConcurrentUploadServer(receivedBodies);
    final uploader = FileUploader(
      DioClient(Dio()),
      FileUtils(),
    );
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');

    final attachments = await Future.wait([
      uploader.uploadAttachment(
        const UploadTaskId('upload-a'),
        FileInfo(fileName: 'a.pdf', fileSize: sourceA.length, filePath: fileA.path),
        uploadUri,
      ),
      uploader.uploadAttachment(
        const UploadTaskId('upload-b'),
        FileInfo(fileName: 'b.pdf', fileSize: sourceB.length, filePath: fileB.path),
        uploadUri,
      ),
    ]).timeout(const Duration(seconds: 30));

    expect(attachments.map((attachment) => attachment.name), containsAll(['a.pdf', 'b.pdf']));
    expect(receivedBodies.length, 2);
    expect(receivedBodies.map(base64Encode), containsAll([base64Encode(sourceA), base64Encode(sourceB)]));
  });

  test('aborts the in-flight request when the upload CancelToken is cancelled', () async {
    final sourceBytes = List<int>.generate(2048, (index) => index % 256);
    final directory = await Directory.systemTemp.createTemp('cancel-upload-');
    addTearDown(() async {
      await directory.delete(recursive: true);
    });
    final file = File('${directory.path}/a.pdf');
    await file.writeAsBytes(sourceBytes);

    final requestReceived = Completer<void>();
    final releaseResponse = Completer<void>();
    final server = await startStalledUploadServer(
      requestReceived: requestReceived,
      releaseResponse: releaseResponse,
    );
    final uploader = FileUploader(
      DioClient(Dio()),
      FileUtils(),
    );
    final cancelToken = CancelToken();

    final uploadFuture = uploader.uploadAttachment(
      const UploadTaskId('upload-cancel'),
      FileInfo(fileName: 'a.pdf', fileSize: sourceBytes.length, filePath: file.path),
      Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
      cancelToken: cancelToken,
    );

    await requestReceived.future.timeout(const Duration(seconds: 30));
    cancelToken.cancel();

    // The worker-isolate path used to drop the CancelToken, so the request ran
    // to completion and only the UI pretended the upload was cancelled.
    await expectLater(
      uploadFuture,
      throwsA(isA<DioException>().having(
        (exception) => exception.type,
        'type',
        DioExceptionType.cancel,
      )),
    );
  });

  group('web', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);
    tearDown(() => PlatformInfo.isTestingForWeb = false);

    test('uploads from bytes and never reads a local path, even when one is set', () async {
      final sourceBytes = Uint8List.fromList(List<int>.generate(512, (index) => index % 256));
      final receivedBodies = <List<int>>[];
      final server = await startRecordingUploadServer(receivedBodies);
      final uploader = FileUploader(DioClient(Dio()), FileUtils());

      final attachment = await uploader.uploadAttachment(
        const UploadTaskId('upload-web'),
        FileInfo(
          fileName: 'a.pdf',
          fileSize: sourceBytes.length,
          // A path that does not exist on disk: on web it must never be opened.
          filePath: '/definitely/not/on/disk/a.pdf',
          bytes: sourceBytes,
          type: 'application/pdf',
        ),
        Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
      ).timeout(const Duration(seconds: 30));

      expect(attachment.name, 'a.pdf');
      expect(receivedBodies.single, sourceBytes);
    });

    test('replays from streamData, so the 401 retry never needs the file system', () async {
      final sourceBytes = Uint8List.fromList(<int>[9, 8, 7]);
      final receivedBodies = <List<int>>[];
      final server = await startRecordingUploadServer(receivedBodies);
      late Map<dynamic, dynamic> capturedUploadExtra;

      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        capturedUploadExtra =
            options.extra[FileUploader.uploadAttachmentExtraKey] as Map<dynamic, dynamic>;
        handler.next(options);
      }));

      await FileUploader(DioClient(dio), FileUtils()).uploadAttachment(
        const UploadTaskId('upload-web-extra'),
        FileInfo(
          fileName: 'a.pdf',
          fileSize: sourceBytes.length,
          filePath: '/definitely/not/on/disk/a.pdf',
          bytes: sourceBytes,
          type: 'application/pdf',
        ),
        Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
      ).timeout(const Duration(seconds: 30));

      expect(capturedUploadExtra.containsKey(FileUploader.filePathExtraKey), isFalse);
      expect(capturedUploadExtra[FileUploader.streamDataExtraKey], isA<Stream<List<int>>>());
    });

    test('resolves the charset of a text/plain attachment from bytes', () async {
      final sourceBytes = Uint8List.fromList(utf8.encode('hello charset'));
      final receivedBodies = <List<int>>[];
      final server = await startRecordingUploadServer(receivedBodies);

      final attachment = await FileUploader(DioClient(Dio()), FileUtils()).uploadAttachment(
        const UploadTaskId('upload-web-charset'),
        FileInfo(
          fileName: 'note.txt',
          fileSize: sourceBytes.length,
          bytes: sourceBytes,
          type: FileUtils.TEXT_PLAIN_MIME_TYPE,
        ),
        Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
      ).timeout(const Duration(seconds: 30));

      expect(attachment.charset, isNotNull);
      expect(attachment.charset, attachment.charset!.toLowerCase());
    });

    test('throws MissingAttachmentSourceException when there is no body source', () async {
      final receivedBodies = <List<int>>[];
      final server = await startRecordingUploadServer(receivedBodies);

      await expectLater(
        FileUploader(DioClient(Dio()), FileUtils()).uploadAttachment(
          const UploadTaskId('upload-web-empty'),
          FileInfo(fileName: 'a.pdf', fileSize: 0, filePath: '', type: 'application/pdf'),
          Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
        ),
        throwsA(isA<MissingAttachmentSourceException>()),
      );
      // It must fail loudly instead of silently uploading a 0-byte attachment.
      expect(receivedBodies, isEmpty);
    });
  });

  test('resolves the charset of a text/plain attachment read from disk', () async {
    const content = 'hello charset';
    final receivedBodies = <List<int>>[];

    final attachment = await uploadTextFileFromDisk(
      fileName: 'note.txt',
      content: content,
      receivedBodies: receivedBodies,
    );

    expect(attachment.charset, isNotNull);
    expect(receivedBodies.single, utf8.encode(content));
  });

  test('bounds the charset probe without truncating the uploaded file', () async {
    // Comfortably past the 256 KiB charset sample bound.
    final content = 'charset detection line\n' * 40000;
    final receivedBodies = <List<int>>[];

    final attachment = await uploadTextFileFromDisk(
      fileName: 'big.txt',
      content: content,
      receivedBodies: receivedBodies,
    );

    expect(attachment.charset, isNotNull);
    expect(receivedBodies.single.length, utf8.encode(content).length);
  });

  test('leaves the charset unset for a non text/plain attachment', () async {
    final receivedBodies = <List<int>>[];
    final server = await startRecordingUploadServer(receivedBodies);

    final attachment = await FileUploader(DioClient(Dio()), FileUtils()).uploadAttachment(
      const UploadTaskId('upload-binary'),
      FileInfo(
        fileName: 'a.pdf',
        fileSize: 3,
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        type: 'application/pdf',
      ),
      Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    ).timeout(const Duration(seconds: 30));

    expect(attachment.charset, isNull);
  });

  test('keeps a completed upload when the charset probe fails', () async {
    final directory = await Directory.systemTemp.createTemp('charset-gone-');
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });
    final file = File('${directory.path}/note.txt');
    await file.writeAsString('hello charset');

    final requestReceived = Completer<void>();
    final releaseResponse = Completer<void>();
    final server = await startStalledUploadServer(
      requestReceived: requestReceived,
      releaseResponse: releaseResponse,
    );

    final uploadFuture = FileUploader(DioClient(Dio()), FileUtils()).uploadAttachment(
      const UploadTaskId('upload-charset-gone'),
      FileInfo(
        fileName: 'note.txt',
        fileSize: await file.length(),
        filePath: file.path,
        type: FileUtils.TEXT_PLAIN_MIME_TYPE,
      ),
      Uri.parse('http://${server.address.address}:${server.port}/upload/account-id'),
    );

    // Drop the file after the server has the blob but before the charset probe.
    await requestReceived.future.timeout(const Duration(seconds: 30));
    await directory.delete(recursive: true);
    releaseResponse.complete();

    final attachment = await uploadFuture.timeout(const Duration(seconds: 30));

    // The blob is already stored server-side, so the attachment must survive
    // with an unknown charset rather than the upload reporting a failure.
    expect(attachment.name, 'note.txt');
    expect(attachment.charset, isNull);
  });
}
