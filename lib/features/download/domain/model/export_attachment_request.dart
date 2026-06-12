import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_request.dart';

class ExportAttachmentRequest extends ExportRequest {
  final Attachment attachment;
  final String baseDownloadUrl;

  const ExportAttachmentRequest({
    required this.attachment,
    required super.accountId,
    required this.baseDownloadUrl,
    required super.cancelToken,
    super.fallbackToken,
  });
}
