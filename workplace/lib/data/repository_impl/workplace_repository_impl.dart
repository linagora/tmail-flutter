import '../datasource/workplace_datasource.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/entity/workplace_request_context.dart';
import '../model/workplace_request_transfer.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';
import '../../domain/entity/drive_uploaded_file.dart';
import '../../domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;

  WorkplaceRepositoryImpl(this._dataSource);

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
    WorkplaceRequestTransfer transfer = const WorkplaceRequestTransfer(),
  }) => _dataSource.uploadFile(context: context, spec: spec, transfer: transfer);
}
