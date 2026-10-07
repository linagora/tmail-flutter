import '../datasource/workplace_datasource.dart';
import '../datasource/workplace_drive_datasource.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/entity/workplace_request_context.dart';
import '../../domain/entity/workplace_upload_transfer.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';
import '../../domain/entity/drive_uploaded_file.dart';
import '../../domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;
  final WorkplaceDriveDataSource _driveDataSource;

  WorkplaceRepositoryImpl(this._dataSource, this._driveDataSource);

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) => _dataSource.createIntent(
    platformUrl: platformUrl,
    accessMode: accessMode,
    config: config,
  );

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);

  @override
  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer = const WorkplaceUploadTransfer(),
  }) => _driveDataSource.uploadFile(context: context, spec: spec, transfer: transfer);
}
