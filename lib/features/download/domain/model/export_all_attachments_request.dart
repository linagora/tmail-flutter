import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/oidc/token_oidc.dart';

class ExportAllAttachmentsRequest {
  final AccountId accountId;
  final EmailId emailId;
  final String baseDownloadAllUrl;
  final String outputFileName;
  final CancelToken cancelToken;
  final TokenOIDC? fallbackToken;

  const ExportAllAttachmentsRequest({
    required this.accountId,
    required this.emailId,
    required this.baseDownloadAllUrl,
    required this.outputFileName,
    required this.cancelToken,
    this.fallbackToken,
  });
}
