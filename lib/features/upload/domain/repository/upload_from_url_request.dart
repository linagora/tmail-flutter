import 'package:dio/dio.dart';

class UploadFromUrlRequest {
  final Uri uploadUri;
  final Uri attachmentUrl;
  final String name;
  final String mimeType;
  final CancelToken? cancelToken;

  const UploadFromUrlRequest({
    required this.uploadUri,
    required this.attachmentUrl,
    required this.name,
    required this.mimeType,
    this.cancelToken,
  });
}
