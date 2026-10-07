import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/domain/entity/drive_uploaded_file.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/entity/workplace_upload_source.dart';
import 'package:workplace/domain/entity/workplace_upload_transfer.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/usecase/upload_drive_file_interactor.dart';

class _StubUploadSource implements WorkplaceUploadSource {
  const _StubUploadSource();

  @override
  Object? get requestData => 'bytes';

  @override
  Map<String, dynamic> get dioExtra => const {};
}

/// Records the upload and share-link calls; [uploadError] makes the upload
/// fail, [linkError] makes the share link fail, and [onUploaded] runs once the
/// upload has succeeded.
class _RecordingRepository extends Fake implements WorkplaceRepository {
  final Object? uploadError;
  final Object? linkError;
  final void Function()? onUploaded;
  WorkplaceRequestContext? uploadContext;
  WorkplaceUploadFileSpec? uploadSpec;
  WorkplaceUploadTransfer? uploadTransfer;
  WorkplaceRequestContext? linkContext;
  String? linkFileId;

  _RecordingRepository({this.uploadError, this.linkError, this.onUploaded});

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) async {
    uploadContext = context;
    uploadSpec = spec;
    uploadTransfer = transfer;
    if (uploadError != null) throw uploadError!;
    onUploaded?.call();
    return const DriveUploadedFile(fileId: 'file-1', name: 'report (1).pdf');
  }

  @override
  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  }) async {
    linkContext = context;
    linkFileId = fileId;
    if (linkError != null) throw linkError!;
    return Uri.parse('https://user-drive.example.com/public?sharecode=abc123');
  }
}

void main() {
  final context = WorkplaceRequestContext(
    platformUrl: Uri.parse('https://user.example.com'),
    accessMode: const BearerTokenAccessMode('test-token'),
  );
  const spec = WorkplaceUploadFileSpec(
    fileName: 'report.pdf',
    mimeType: 'application/pdf',
    fileSize: 1234,
    source: _StubUploadSource(),
  );

  group('UploadDriveFileInteractor::execute::', () {
    test('uploads with the long timeout and the cancel signal, then links the uploaded file', () async {
      final repository = _RecordingRepository();
      final cancelSignal = Completer<void>().future;

      final link = await UploadDriveFileInteractor(repository).execute(
        context: context,
        spec: spec,
        cancelSignal: cancelSignal,
      );

      expect(repository.uploadTransfer?.timeout, equals(const Duration(minutes: 30)));
      expect(repository.uploadTransfer?.cancelSignal, same(cancelSignal));
      expect(repository.linkContext, same(context));
      expect(repository.linkFileId, equals('file-1'));
      expect(link.toString(), equals('https://user-drive.example.com/public?sharecode=abc123'));
    });

    test('forwards upload progress to onProgress', () async {
      final repository = _RecordingRepository();
      final progress = <List<int>>[];

      await UploadDriveFileInteractor(repository).execute(
        context: context,
        spec: spec,
        onProgress: (count, total) => progress.add([count, total]),
      );
      repository.uploadTransfer?.onProgress?.call(512, 1234);

      expect(progress, equals([[512, 1234]]));
    });

    test('sends no progress callback when onProgress is null', () async {
      final repository = _RecordingRepository();

      await UploadDriveFileInteractor(repository).execute(context: context, spec: spec);

      expect(repository.uploadTransfer?.onProgress, isNull);
    });

    test('does not mint a link when the upload fails', () async {
      final repository = _RecordingRepository(uploadError: StateError('upload failed'));

      await expectLater(
        UploadDriveFileInteractor(repository).execute(context: context, spec: spec),
        throwsA(isA<StateError>()),
      );
      expect(repository.linkFileId, isNull);
    });

    test('uploads with the caller context and spec', () async {
      final repository = _RecordingRepository();

      await UploadDriveFileInteractor(repository).execute(context: context, spec: spec);

      expect(repository.uploadContext, same(context));
      expect(repository.uploadSpec, same(spec));
    });

    test('surfaces the share link failure after a successful upload', () async {
      final repository = _RecordingRepository(linkError: StateError('link failed'));

      await expectLater(
        UploadDriveFileInteractor(repository).execute(context: context, spec: spec),
        throwsA(isA<StateError>()),
      );
      expect(repository.uploadSpec, same(spec));
      expect(repository.linkFileId, equals('file-1'));
    });

    test('does not mint a link when cancelled after the upload succeeded', () async {
      final cancel = Completer<void>();
      final repository = _RecordingRepository(onUploaded: cancel.complete);

      await UploadDriveFileInteractor(repository)
          .execute(context: context, spec: spec, cancelSignal: cancel.future)
          .catchError((_) => Uri());

      expect(repository.uploadSpec, same(spec));
      expect(repository.linkFileId, isNull);
    });
  });
}
