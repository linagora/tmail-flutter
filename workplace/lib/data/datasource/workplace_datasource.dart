import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';
import '../../domain/entity/workplace_request_context.dart';
import '../../domain/entity/workplace_upload_transfer.dart';
import '../../domain/entity/workplace_upload_file_spec.dart';
import '../../domain/entity/drive_uploaded_file.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);

  Future<DriveUploadedFile> uploadFile({
    required WorkplaceRequestContext context,
    required WorkplaceUploadFileSpec spec,
    WorkplaceUploadTransfer transfer,
  });
}
