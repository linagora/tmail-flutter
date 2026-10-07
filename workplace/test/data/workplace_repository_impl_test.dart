import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource/workplace_datasource.dart';
import 'package:workplace/data/datasource_impl/workplace_request_executor.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/entity/drive_uploaded_file.dart';
import 'package:workplace/domain/entity/workplace_access_mode.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_upload_file_spec.dart';
import 'package:workplace/domain/entity/workplace_upload_source.dart';
import 'package:workplace/domain/entity/workplace_upload_transfer.dart';

class _StubUploadSource implements WorkplaceUploadSource {
  const _StubUploadSource();

  @override
  Object? get requestData => 'bytes';

  @override
  Map<String, dynamic> get dioExtra => const {};
}

/// Records the arguments of the last upload; other calls are out of scope.
class _RecordingDataSource implements WorkplaceDataSource {
  WorkplaceRequestContext? context;
  WorkplaceUploadFileSpec? spec;
  WorkplaceUploadTransfer? transfer;

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) async {
    this.context = context;
    this.spec = spec;
    this.transfer = transfer;
    return const DriveUploadedFile(fileId: 'file-1', name: 'report.pdf');
  }

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) => throw UnimplementedError();

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      throw UnimplementedError();
}

void main() {
  group('WorkplaceRepositoryImpl::uploadFile::', () {
    test('forwards the context, spec and transfer to the datasource', () async {
      final dataSource = _RecordingDataSource();
      final context = WorkplaceRequestContext(
        platformUrl: Uri.parse('https://platform.example.com'),
        accessMode: const BearerTokenAccessMode('test-token'),
      );
      const spec = WorkplaceUploadFileSpec(
        fileName: 'report.pdf',
        mimeType: 'application/pdf',
        fileSize: 1234,
        source: _StubUploadSource(),
      );
      const transfer = WorkplaceUploadTransfer(timeout: Duration(minutes: 30));

      final result = await WorkplaceRepositoryImpl(dataSource).uploadFile(
        context: context,
        spec: spec,
        transfer: transfer,
      );

      expect(dataSource.context, same(context));
      expect(dataSource.spec, same(spec));
      expect(dataSource.transfer, same(transfer));
      expect(result.fileId, equals('file-1'));
    });
  });
}
