import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/download/domain/model/export_request.dart';

class ExportAllAttachmentsRequest extends ExportRequest {
  final EmailId emailId;
  final String baseDownloadAllUrl;
  final String outputFileName;

  const ExportAllAttachmentsRequest({
    required super.accountId,
    required this.emailId,
    required this.baseDownloadAllUrl,
    required this.outputFileName,
    required super.cancelToken,
    super.fallbackToken,
  });
}
