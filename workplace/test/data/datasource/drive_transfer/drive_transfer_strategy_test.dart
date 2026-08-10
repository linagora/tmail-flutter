import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';

final _doc = DriveDocument(
  id: 'doc-1',
  name: 'file.bin',
  size: 16,
  mimeType: 'application/octet-stream',
  downloadLink: Uri.parse('https://drive.example/file'),
);

final _uploadUri = Uri.parse('https://jmap.example/upload');

/// Records the disposal of the temp file the strategy staged.
class _RecordingStagedFile {
  final List<String> deleted = [];

  FileBackedStagedFile build({Object? throwOnDelete}) => FileBackedStagedFile(
        filePath: '/tmp/file.bin',
        deleteFile: (path) async {
          deleted.add(path);
          if (throwOnDelete != null) throw throwOnDelete;
        },
        fileName: 'file.bin',
        fileSize: 16,
      );
}

/// Exercises the `transfer()` template with both legs fully controllable.
class _FakeStrategy extends DriveTransferStrategy<FileBackedStagedFile> {
  _FakeStrategy({
    required this.staged,
    this.stageError,
    this.uploadError,
  });

  final FileBackedStagedFile staged;
  final Object? stageError;
  final Object? uploadError;

  final attachment = Attachment(name: 'file.bin');
  bool uploadCalled = false;

  @override
  Future<FileBackedStagedFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  }) async {
    if (stageError != null) throw stageError!;
    return staged;
  }

  @override
  Future<Attachment> upload(
      DriveUploadRequest<FileBackedStagedFile> request) async {
    uploadCalled = true;
    if (uploadError != null) throw uploadError!;
    return attachment;
  }
}

Future<Attachment> _transfer(_FakeStrategy strategy) =>
    strategy.transfer(DriveTransferRequest(
      doc: _doc,
      uploadUri: _uploadUri,
      authHeader: 'Bearer token',
      onDownloadProgress: (_, __) {},
      onUploadProgress: (_, __) {},
      cancelToken: CancelToken(),
    ));

void main() {
  test('disposes the staged file after a successful upload', () async {
    final recorder = _RecordingStagedFile();
    final strategy = _FakeStrategy(staged: recorder.build());

    final attachment = await _transfer(strategy);

    expect(attachment, same(strategy.attachment));
    expect(recorder.deleted, ['/tmp/file.bin']);
  });

  test('disposes the staged file when the upload throws, and rethrows',
      () async {
    final recorder = _RecordingStagedFile();
    final error = StateError('upload failed');
    final strategy = _FakeStrategy(staged: recorder.build(), uploadError: error);

    await expectLater(_transfer(strategy), throwsA(same(error)));

    expect(recorder.deleted, ['/tmp/file.bin']);
  });

  test('disposes the staged file when the upload is cancelled', () async {
    final recorder = _RecordingStagedFile();
    final strategy = _FakeStrategy(
      staged: recorder.build(),
      uploadError: DioException(
        requestOptions: RequestOptions(path: _uploadUri.toString()),
        type: DioExceptionType.cancel,
      ),
    );

    await expectLater(
      _transfer(strategy),
      throwsA(isA<DioException>()
          .having((e) => e.type, 'type', DioExceptionType.cancel)),
    );

    expect(recorder.deleted, ['/tmp/file.bin']);
  });

  test('a failing dispose does not fail an otherwise successful transfer',
      () async {
    final recorder = _RecordingStagedFile();
    final strategy = _FakeStrategy(
      staged: recorder.build(throwOnDelete: StateError('delete failed')),
    );

    final attachment = await _transfer(strategy);

    expect(attachment, same(strategy.attachment));
    expect(recorder.deleted, ['/tmp/file.bin']);
  });

  test('a failing dispose does not replace the upload error', () async {
    final recorder = _RecordingStagedFile();
    final uploadError = StateError('upload failed');
    final strategy = _FakeStrategy(
      staged: recorder.build(throwOnDelete: StateError('delete failed')),
      uploadError: uploadError,
    );

    await expectLater(_transfer(strategy), throwsA(same(uploadError)));

    expect(recorder.deleted, ['/tmp/file.bin']);
  });

  test('does not upload or dispose when staging fails', () async {
    final recorder = _RecordingStagedFile();
    final error = StateError('stage failed');
    final strategy = _FakeStrategy(staged: recorder.build(), stageError: error);

    await expectLater(_transfer(strategy), throwsA(same(error)));

    expect(strategy.uploadCalled, isFalse);
    expect(recorder.deleted, isEmpty);
  });
}
