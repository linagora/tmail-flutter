import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/quotas/get/get_quota_method.dart';
import 'package:jmap_dart_client/jmap/quotas/get/get_quota_response.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/quotas/domain/exceptions/quotas_exception.dart';

class QuotasAPI {
  final HttpClient _httpClient;

  QuotasAPI(this._httpClient);

  Future<List<Quota>> getQuotas(AccountId accountId) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final getQuotaMethod = GetQuotaMethod(accountId);
    final getQuotaInvocation = requestBuilder.invocation(getQuotaMethod);
    final response = await (requestBuilder
        ..usings(getQuotaMethod.requiredCapabilities))
      .build()
      .execute();

    final getQuotaResponse = response.parse<GetQuotaResponse>(
      getQuotaInvocation.methodCallId,
      GetQuotaResponse.deserialize,
    );

    if (getQuotaResponse?.list.isNotEmpty == true) {
      return getQuotaResponse!.list;
    } else {
      throw NotFoundQuotasException();
    }
  }
}
