import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
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
}
