import '../entity/workplace_intent.dart';
import '../entity/workplace_access_mode.dart';
import '../entity/workplace_intent_config.dart';
import '../entity/workplace_request_context.dart';
import '../entity/workplace_upload_transfer.dart';
import '../entity/workplace_upload_file_spec.dart';
import '../entity/drive_uploaded_file.dart';

abstract class WorkplaceRepository {
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

  Future<Uri> createShareLink({
    required WorkplaceRequestContext context,
    required String fileId,
  });
}
