import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/oidc/token_oidc.dart';

abstract class ExportRequest {
  final AccountId accountId;
  final CancelToken cancelToken;
  final TokenOIDC? fallbackToken;

  const ExportRequest({
    required this.accountId,
    required this.cancelToken,
    this.fallbackToken,
  });
}
