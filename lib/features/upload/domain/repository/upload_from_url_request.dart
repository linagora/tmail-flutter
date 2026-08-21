import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class UploadFromUrlRequest {
  final AccountId accountId;
  final Uri uploadUri;
  final Uri attachmentUrl;
  final String name;
  final String mimeType;
  final CancelToken? cancelToken;

  const UploadFromUrlRequest({
    required this.accountId,
    required this.uploadUri,
    required this.attachmentUrl,
    required this.name,
    required this.mimeType,
    this.cancelToken,
  });
}
