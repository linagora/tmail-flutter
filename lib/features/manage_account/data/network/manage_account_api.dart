import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_method.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_response.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

class ManageAccountAPI {

  final HttpClient _httpClient;

  ManageAccountAPI(this._httpClient);

  Future<IdentitiesResponse> getAllIdentities(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final jmapRequestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);
    final getIdentityMethod = GetIdentityMethod(accountId);
    final queryInvocation = jmapRequestBuilder.invocation(getIdentityMethod);

    final result = await (jmapRequestBuilder
        ..usings(getIdentityMethod.requiredCapabilities))
      .build()
      .execute();

    final response = result.parse<GetIdentityResponse>(
      queryInvocation.methodCallId,
      GetIdentityResponse.deserialize);

    return IdentitiesResponse(identities: response?.list, state: response?.state);
  }
}