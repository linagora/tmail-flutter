import 'package:core/utils/app_logger.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/set/set_forward_method.dart';
import 'package:forward/forward/set/set_forward_response.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/forward_exception.dart';

class ForwardingAPI with HandleSetErrorMixin {
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

    final tMailForwardResult = result?.list.firstOrNull;
    if (tMailForwardResult == null) {
      throw NotFoundForwardException();
    }

    return tMailForwardResult;
  }

  Future<TMailForward> updateForward(AccountId accountId, TMailForward forward) async {
    log('ForwardingAPI::updateForward: ${forward.toJson()}');
    final setForwardMethod = SetForwardMethod(accountId)
      ..addUpdatesSingleton({
        ForwardIdSingleton.forwardIdSingleton.id : forward
      });

    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);
    final setForwardInvocation = requestBuilder.invocation(setForwardMethod);

    final getForwardMethod = GetForwardMethod(accountId)
      ..addIds({ForwardIdSingleton.forwardIdSingleton.id});
    final getForwardInvocation = requestBuilder.invocation(getForwardMethod);

    final response = await (requestBuilder
        ..usings(setForwardMethod.requiredCapabilities))
      .build()
      .execute();

    final setForwardResponse = response.parse<SetForwardResponse>(
      setForwardInvocation.methodCallId,
      SetForwardResponse.deserialize,
    );

    final mapErrors = handleSetResponse([setForwardResponse]);
    if (mapErrors.isNotEmpty) {
      throw SetMethodException(mapErrors);
    }

    final updatedForward = setForwardResponse?.updated;
    if (updatedForward?.isNotEmpty != true) {
      throw UpdateForwardException();
    }

    final getForwardResponse = response.parse<GetForwardResponse>(
      getForwardInvocation.methodCallId,
      GetForwardResponse.deserialize,
    );

    final newForward = getForwardResponse?.list.firstOrNull;
    if (newForward == null) {
      throw NotFoundForwardException();
    }

    return newForward;
  }
}