import 'package:core/utils/app_logger.dart';
import 'package:delegation/delegation.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';

class DelegateApi with HandleSetErrorMixin {
  final HttpClient _httpClient;

  DelegateApi(this._httpClient);

  Future<List<Delegate>> getDelegates(AccountId accountId) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = GetDelegateMethod(accountId);
    final invocation = builder.invocation(method);

    final result = await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<GetDelegateResponse>(
      invocation.methodCallId,
      GetDelegateResponse.deserialize,
    );

    return response?.list ?? [];
  }

  Future<AddDelegatesResult> addDelegates(AccountId accountId, Set<String> usernames) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setMethod = SetDelegateMethod(accountId);
    final creationIdToUsername = <Id, String>{};
    var index = 0;
    for (final username in usernames) {
      final creationId = Id('c$index');
      creationIdToUsername[creationId] = username;
      setMethod.addCreate(creationId, DelegateCreation(username: username));
      index++;
    }
    final setInvocation = builder.invocation(setMethod);
    final getMethod = GetDelegateMethod(accountId);
    final getInvocation = builder.invocation(getMethod);

    final result = await (builder..usings(setMethod.requiredCapabilities)).build().execute();

    final setResponse = result.parse<SetDelegateResponse>(
      setInvocation.methodCallId,
      SetDelegateResponse.deserialize,
    );

    final addedUsernames = <String>[];
    final rejectedUsernames = <String, SetError?>{};
    for (final entry in creationIdToUsername.entries) {
      final creationId = entry.key;
      final username = entry.value;
      if (setResponse?.created?.containsKey(creationId) == true) {
        addedUsernames.add(username);
      } else if (setResponse?.notCreated?.containsKey(creationId) == true) {
        rejectedUsernames[username] = setResponse!.notCreated![creationId];
      } else {
        rejectedUsernames[username] = null;
      }
    }

    return AddDelegatesResult(
      addedUsernames: addedUsernames,
      rejectedUsernames: rejectedUsernames,
      delegates: _readDelegatesOrNull(result, getInvocation.methodCallId),
    );
  }

  Future<RemoveDelegateResult> removeDelegate(AccountId accountId, Delegate delegate) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setMethod = SetDelegateMethod(accountId)..addDestroy({delegate.id});
    final setInvocation = builder.invocation(setMethod);
    final getMethod = GetDelegateMethod(accountId);
    final getInvocation = builder.invocation(getMethod);

    final result = await (builder..usings(setMethod.requiredCapabilities)).build().execute();

    final setResponse = result.parse<SetDelegateResponse>(
      setInvocation.methodCallId,
      SetDelegateResponse.deserialize,
    );

    if (setResponse?.destroyed?.contains(delegate.id) != true) {
      throw parseErrorForSetResponse(setResponse, delegate.id);
    }

    return RemoveDelegateResult(
      removedDelegate: delegate,
      delegates: _readDelegatesOrNull(result, getInvocation.methodCallId),
    );
  }

  /// The list re-read in the same request, null when that read failed.
  List<Delegate>? _readDelegatesOrNull(ResponseObject result, MethodCallId getCallId) {
    try {
      return result.parse<GetDelegateResponse>(getCallId, GetDelegateResponse.deserialize)?.list ?? [];
    } catch (e) {
      logWarning('DelegateApi::_readDelegatesOrNull(): $e');
      return null;
    }
  }
}
