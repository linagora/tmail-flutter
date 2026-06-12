import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/oidc/token_oidc.dart';

class ExportAttachmentRequest {
  final Attachment attachment;
  final AccountId accountId;
  final String baseDownloadUrl;
  final CancelToken cancelToken;
  final TokenOIDC? fallbackToken;

  const ExportAttachmentRequest({
    required this.attachment,
    required this.accountId,
    required this.baseDownloadUrl,
    required this.cancelToken,
    this.fallbackToken,
  });
}
