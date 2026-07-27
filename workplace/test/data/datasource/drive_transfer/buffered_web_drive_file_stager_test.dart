import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/workplace_dio.dart';
import 'package:workplace/domain/entity/drive_document.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<int> bytes;
  _FakeHttpClientAdapter(this.bytes);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    options.onReceiveProgress?.call(bytes.length, bytes.length);
    return ResponseBody.fromBytes(bytes, 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio originalDio;

  setUp(() => originalDio = WorkplaceDio.instance);
  tearDown(() => WorkplaceDio.setInstance(originalDio));

  test('buffers the full response and forwards onReceiveProgress', () async {
    final bytes = List<int>.generate(16, (i) => i);
    WorkplaceDio.setInstance(Dio()..httpClientAdapter = _FakeHttpClientAdapter(bytes));

    final progress = <List<int>>[];
    final staged = await BufferedWebDriveFileStager().stage(
      doc: DriveDocument(
        id: 'doc-1',
        name: 'file.bin',
        size: bytes.length,
        mimeType: 'application/octet-stream',
        downloadLink: Uri.parse('https://drive.example/file'),
      ),
      onDownloadProgress: (r, t) => progress.add([r, t]),
      cancelToken: CancelToken(),
    );

    expect(staged, isA<BytesStagedFile>());
    expect((staged as BytesStagedFile).bytes, bytes);
    expect(progress, isNotEmpty);
    expect(progress.last.first, bytes.length);

    await staged.dispose();
  });
}
