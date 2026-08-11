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
  DriveUploadRequest<FileBackedStagedFile>? uploadRequest;

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
    uploadRequest = request;
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

/// Every path where `transfer()` must dispose the staged file exactly once:
/// the upload outcome ([uploadError] null means success) is independent of
/// whether disposal itself fails ([throwOnDelete]).
void _disposesStagedFileTest(
  String description, {
  Object? throwOnDelete,
  Object? uploadError,
}) {
  test(description, () async {
    final recorder = _RecordingStagedFile();
    final strategy = _FakeStrategy(
      staged: recorder.build(throwOnDelete: throwOnDelete),
      uploadError: uploadError,
    );

    if (uploadError == null) {
      expect(await _transfer(strategy), same(strategy.attachment));
    } else {
      await expectLater(_transfer(strategy), throwsA(same(uploadError)));
    }

    expect(recorder.deleted, ['/tmp/file.bin']);
  });
}

void main() {
  _disposesStagedFileTest('disposes the staged file after a successful upload');

  _disposesStagedFileTest(
    'disposes the staged file when the upload throws, and rethrows',
    uploadError: StateError('upload failed'),
  );

  _disposesStagedFileTest(
    'disposes the staged file when the upload is cancelled',
    uploadError: DioException(
      requestOptions: RequestOptions(path: _uploadUri.toString()),
      type: DioExceptionType.cancel,
    ),
  );

  _disposesStagedFileTest(
    'a failing dispose does not fail an otherwise successful transfer',
    throwOnDelete: StateError('delete failed'),
  );

  _disposesStagedFileTest(
    'a failing dispose does not replace the upload error',
    throwOnDelete: StateError('delete failed'),
    uploadError: StateError('upload failed'),
  );

  test('transfer() carries every request field onto the upload leg', () async {
    final recorder = _RecordingStagedFile();
    final staged = recorder.build();
    final strategy = _FakeStrategy(staged: staged);
    // Distinct closure instances, so `same()` also catches the two progress
    // callbacks being swapped.
    final request = DriveTransferRequest(
      doc: _doc,
      uploadUri: _uploadUri,
      authHeader: 'Bearer token',
      onDownloadProgress: (_, __) {},
      onUploadProgress: (_, __) {},
      cancelToken: CancelToken(),
    );

    await strategy.transfer(request);

    final uploaded = strategy.uploadRequest!;
    expect(uploaded.staged, same(staged));
    expect(uploaded.uploadUri, same(request.uploadUri));
    expect(uploaded.authHeader, request.authHeader);
    expect(uploaded.onUploadProgress, same(request.onUploadProgress));
    expect(uploaded.cancelToken, same(request.cancelToken));
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
