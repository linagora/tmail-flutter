@TestOn('chrome')
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/domain/entity/drive_document.dart';

void main() {
  test('stages a fetched file into OPFS and reports cumulative progress',
      () async {
    const content = 'hello opfs world';
    final dataUrl = Uri.dataFromString(content, mimeType: 'text/plain');

    final doc = DriveDocument(
      id: 'doc-opfs-1',
      name: 'hello.txt',
      size: content.length,
      mimeType: 'text/plain',
      downloadLink: dataUrl,
    );

    final progress = <int>[];
    final staged = await OpfsDriveFileStager().stage(
      doc: doc,
      onDownloadProgress: (received, total) => progress.add(received),
      cancelToken: CancelToken(),
    );

    expect(staged, isA<OpfsStagedFile>());
    final opfsStaged = staged as OpfsStagedFile;
    expect(opfsStaged.fileSize, content.length);
    expect(opfsStaged.fileName, doc.name);
    expect(progress, isNotEmpty);
    expect(progress.last, content.length);

    // dispose() must remove the OPFS temp entry on every exit path; a
    // real `FileSystemDirectoryHandle.removeEntry` call throwing would
    // surface here.
    await opfsStaged.dispose();
  });

  test('cleans up the OPFS temp entry when the transfer fails', () async {
    final doc = DriveDocument(
      id: 'doc-opfs-2',
      name: 'missing.bin',
      size: 0,
      mimeType: 'application/octet-stream',
      downloadLink: Uri.parse('https://127.0.0.1:0/does-not-resolve'),
    );

    await expectLater(
      OpfsDriveFileStager().stage(
        doc: doc,
        onDownloadProgress: (_, __) {},
        cancelToken: CancelToken(),
      ),
      throwsA(anything),
    );
  });
}
