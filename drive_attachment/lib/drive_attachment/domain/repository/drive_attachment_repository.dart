import 'package:drive_attachment/drive_attachment/domain/entity/drive_intent.dart';

abstract class DriveAttachmentRepository {
  Future<DriveIntent> createIntent(Uri platformUrl, String accessToken);
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
