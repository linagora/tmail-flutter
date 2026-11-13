import 'package:delegation/delegation.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';

class DelegatedAccountApi with HandleSetErrorMixin {
  final HttpClient _httpClient;

  DelegatedAccountApi(this._httpClient);

  Future<List<DelegatedAccount>> getDelegatedAccounts(AccountId accountId) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = GetDelegatedAccountMethod(accountId);
    final invocation = builder.invocation(method);

    final result = await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<GetDelegatedAccountResponse>(
      invocation.methodCallId,
      GetDelegatedAccountResponse.deserialize,
    );

    return response?.list ?? [];
  }

  Future<void> removeDelegatedAccount(AccountId accountId, Id delegationId) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = SetDelegatedAccountMethod(accountId)..addDestroy({delegationId});
    final invocation = builder.invocation(method);

    final result = await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<SetDelegatedAccountResponse>(
      invocation.methodCallId,
      SetDelegatedAccountResponse.deserialize,
    );

    if (response?.destroyed?.contains(delegationId) != true) {
      throw parseErrorForSetResponse(response, delegationId);
    }
  }
}
