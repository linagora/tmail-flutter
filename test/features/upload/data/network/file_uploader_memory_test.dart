import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

/// Own file so this test's assertions are not shared with the rest of the
/// upload test suite.
void main() {
  Future<HttpServer> startCountingUploadServer(List<int> totalBytesReceived) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      var total = 0;
      // Drains and sums lengths instead of accumulating the body: a recording
      // server would itself hold the 256 MB this test is trying to rule out.
      await for (final chunk in request) {
        total += chunk.length;
      }
      totalBytesReceived.add(total);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'accountId': 'account-id',
        'blobId': 'blob-id',
        'type': 'application/pdf',
        'size': total,
      }));
      await request.response.close();
    });
    addTearDown(() async {
      await server.close(force: true);
    });
    return server;
  }

  test('keeps a streamed upload from retaining the whole file in memory', () async {
    const chunkSize = 1024 * 1024; // 1 MiB
    const chunkCount = 256; // 256 MiB total
    final totalBytesReceived = <int>[];
    final server = await startCountingUploadServer(totalBytesReceived);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');
    final uploader = FileUploader(DioClient(Dio()), FileUtils());

    var bytesProduced = 0;
    var maxOutstandingBytes = 0;

    // Yields the same 1 MB buffer [chunkCount] times: the producer holds one
    // chunk, not the whole file, mirroring how a real read stream is sliced.
    Stream<List<int>> trackedChunks(int count) async* {
      final chunk = Uint8List(chunkSize);
      for (var i = 0; i < count; i++) {
        bytesProduced += chunk.length;
        yield chunk;
      }
    }

    final onSendController = StreamController<Either<Failure, Success>>();
    final subscription = onSendController.stream.listen((either) {
      either.fold((_) {}, (success) {
        if (success is UploadingAttachmentUploadState) {
          final outstanding = bytesProduced - success.progress;
          if (outstanding > maxOutstandingBytes) {
            maxOutstandingBytes = outstanding;
          }
        }
      });
    });

    await uploader.uploadAttachment(
      const UploadTaskId('upload-memory'),
      FileInfo(
        fileName: 'big.pdf',
        fileSize: chunkSize * chunkCount,
        openRead: ([start, end]) => trackedChunks(chunkCount),
        type: 'application/pdf',
      ),
      uploadUri,
      onSendController: onSendController,
    ).timeout(const Duration(seconds: 30));

    await subscription.cancel();
    await onSendController.close();

    expect(totalBytesReceived, [chunkSize * chunkCount]);
    // A regression that re-materialises the body into one buffer would let the
    // producer race arbitrarily far ahead of what dio has actually sent —
    // outstanding bytes would approach the full 256 MiB. A genuinely streamed
    // upload keeps the gap bounded by socket/dio buffering, not file size.
    expect(maxOutstandingBytes, lessThan(32 * 1024 * 1024));
  });
}
