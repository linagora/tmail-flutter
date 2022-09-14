import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/get/get_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/get/get_vacation_response.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';

class VacationAPI {
  final HttpClient _httpClient;

  VacationAPI(this._httpClient);

  Future<List<VacationResponse>> getAllVacationResponse(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getVacationMethod = GetVacationMethod(accountId);
    final getVacationInvocation = requestBuilder.invocation(getVacationMethod);
    final response = await (requestBuilder
      ..usings(getVacationMethod.requiredCapabilities))
        .build()
        .execute();

    final resultList = response.parse<GetVacationResponse>(
        getVacationInvocation.methodCallId,
        GetVacationResponse.deserialize);

    return resultList?.list ?? <VacationResponse>[];
  }

  Future<List<VacationResponse>> updateVacation(AccountId accountId, VacationResponse vacationResponse) async {
    final setVacationMethod = SetVacationMethod(accountId)
      ..addUpdatesSingleton({
        VacationId.singleton().id : vacationResponse
      });

    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation)
      ..invocation(setVacationMethod);

    final getVacationMethod = GetVacationMethod(accountId);
    final getVacationInvocation = requestBuilder.invocation(getVacationMethod);

    final response = await (requestBuilder
      ..usings(setVacationMethod.requiredCapabilities))
        .build()
        .execute();

    final resultList = response.parse<GetVacationResponse>(
        getVacationInvocation.methodCallId,
        GetVacationResponse.deserialize);

    return resultList?.list ?? <VacationResponse>[];
  }
}