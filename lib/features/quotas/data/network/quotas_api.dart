import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/quotas/get/get_quota_method.dart';
import 'package:jmap_dart_client/jmap/quotas/get/get_quota_response.dart';
import 'package:tmail_ui_user/features/quotas/domain/model/exceptions/quotas_exception.dart';
import 'package:tmail_ui_user/features/quotas/domain/model/quotas_response.dart';

class QuotasAPI {
  final HttpClient _httpClient;

  QuotasAPI(this._httpClient);

  Future<QuotasResponse> getQuotas(AccountId accountId) async {
    final requestBuilder =
        JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final getQuotaMethod = GetQuotaMethod(accountId);
    final getQuotaInvocation = requestBuilder.invocation(getQuotaMethod);
    final response = await (requestBuilder
          ..usings(getQuotaMethod.requiredCapabilities))
        .build()
        .execute();

    final getQuotaResponse = response.parse<GetQuotaResponse>(
        getQuotaInvocation.methodCallId, GetQuotaResponse.deserialize);

    if(getQuotaResponse != null) {
      return QuotasResponse(
        accountId: getQuotaResponse.accountId,
        notFound: getQuotaResponse.notFound,
        quotas: getQuotaResponse.list,
        state: getQuotaResponse.state,
      );
    } else {
      throw NotFoundQuotasException();
    }

  }
}
