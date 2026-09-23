import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';

/// Own file so this test's RSS baseline is not shared with the rest of the
/// upload test suite: it measures, it does not just assert shape.
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

  /// Yields the same 1 MB buffer [chunkCount] times: the producer holds one
  /// chunk, not the whole file, mirroring how a real read stream is sliced.
  Stream<List<int>> generateChunks(int chunkCount, int chunkSize) async* {
    final chunk = Uint8List(chunkSize);
    for (var i = 0; i < chunkCount; i++) {
      yield chunk;
    }
  }

  test('keeps a streamed upload from retaining the whole file in memory', () async {
    const chunkSize = 1024 * 1024; // 1 MiB
    const chunkCount = 256; // 256 MiB total
    final totalBytesReceived = <int>[];
    final server = await startCountingUploadServer(totalBytesReceived);
    final uploadUri = Uri.parse('http://${server.address.address}:${server.port}/upload/account-id');
    final uploader = FileUploader(DioClient(Dio()), FileUtils());

    // A small warm-up pass settles the isolate's baseline RSS before measuring,
    // so one-time allocator/connection warm-up is not charged to the real run.
    await uploader.uploadAttachment(
      const UploadTaskId('upload-memory-warmup'),
      FileInfo(
        fileName: 'warmup.pdf',
        fileSize: chunkSize,
        openRead: ([start, end]) => generateChunks(1, chunkSize),
        type: 'application/pdf',
      ),
      uploadUri,
    ).timeout(const Duration(seconds: 30));

    final baselineRssBytes = ProcessInfo.currentRss;

    await uploader.uploadAttachment(
      const UploadTaskId('upload-memory'),
      FileInfo(
        fileName: 'big.pdf',
        fileSize: chunkSize * chunkCount,
        openRead: ([start, end]) => generateChunks(chunkCount, chunkSize),
        type: 'application/pdf',
      ),
      uploadUri,
    ).timeout(const Duration(seconds: 30));

    final rssDeltaBytes = ProcessInfo.currentRss - baselineRssBytes;

    expect(totalBytesReceived, [chunkSize, chunkSize * chunkCount]);
    // Measured baseline on this streamed path is ~85 MiB (dio/socket buffering,
    // not the file itself). ProcessInfo.currentRss reads the whole OS process,
    // so running the full suite (other concurrent test isolates sharing that
    // process) adds noise — measured up to ~142 MiB there. A regression that
    // re-materialises the body into one buffer has to hold >=256 MiB, so
    // 192 MiB still leaves a clear margin against that regression while
    // tolerating full-suite concurrency noise.
    expect(rssDeltaBytes, lessThan(192 * 1024 * 1024));
  });
}
