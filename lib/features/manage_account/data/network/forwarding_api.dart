import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/set/set_forward_method.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/forward_exception.dart';

class ForwardingAPI {
  final HttpClient _httpClient;

  ForwardingAPI(this._httpClient);

  Future<TMailForward> getForward(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getForwardMethod = GetForwardMethod(
      accountId,
    )..addIds({ForwardIdSingleton.forwardIdSingleton.id});

    final getForwardInvocation = requestBuilder.invocation(getForwardMethod);
    final response = await (requestBuilder
        ..usings(getForwardMethod.requiredCapabilities))
      .build()
      .execute();

    final result = response.parse<GetForwardResponse>(
      getForwardInvocation.methodCallId,
      GetForwardResponse.deserialize);

    final tMailForwardResult = result?.list.first;
    if (tMailForwardResult == null) {
      throw NotFoundForwardException();
    }

    return tMailForwardResult;
  }

  Future<TMailForward> updateForward(AccountId accountId, TMailForward forward) async {
    final setForwardMethod = SetForwardMethod(accountId)
      ..addUpdatesSingleton({
        ForwardIdSingleton.forwardIdSingleton.id : forward
      });

    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation)
      ..invocation(setForwardMethod);

    final getForwardMethod = GetForwardMethod(accountId)
      ..addIds({ForwardIdSingleton.forwardIdSingleton.id});
    final getForwardInvocation = requestBuilder.invocation(getForwardMethod);

    final response = await (requestBuilder
        ..usings(setForwardMethod.requiredCapabilities))
      .build()
      .execute();

    final getForwardResponse = response.parse<GetForwardResponse>(
      getForwardInvocation.methodCallId,
      GetForwardResponse.deserialize);

    final newForward = getForwardResponse?.list.first;
    if (newForward == null) {
      throw NotFoundForwardException();
    }

    return newForward;
  }
}