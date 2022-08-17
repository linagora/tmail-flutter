import 'dart:async';

import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_method.dart';
import 'package:jmap_dart_client/jmap/identities/get/get_identity_response.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/identities/set/set_identity_method.dart';
import 'package:jmap_dart_client/jmap/identities/set/set_identity_response.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/get/get_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/get/get_vacation_response.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/get/get_rule_filter_response.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/set/set_rule_filter_method.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/manage_account/data/extensions/list_tmail_rule_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/forward_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';

class ManageAccountAPI {

  final HttpClient _httpClient;

  ManageAccountAPI(this._httpClient);

  Future<IdentitiesResponse> getAllIdentities(AccountId accountId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();
    final jmapRequestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);
    final getIdentityMethod = GetIdentityMethod(accountId);
    if (properties != null) {
      getIdentityMethod.addProperties(properties);
    }
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

  Future<Identity> createNewIdentity(AccountId accountId, CreateNewIdentityRequest identityRequest) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addCreate(identityRequest.creationId, identityRequest.newIdentity);

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
        ..usings(setIdentityMethod.requiredCapabilities))
      .build()
      .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return Future.sync(() async {
      return setIdentityResponse!.created![identityRequest.creationId]!;
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> deleteIdentity(AccountId accountId, IdentityId identityId) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addDestroy({identityId.id});

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
      ..usings(setIdentityMethod.requiredCapabilities))
        .build()
        .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return Future.sync(() async {
      return setIdentityResponse?.destroyed?.contains(identityId.id) == true;
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> editIdentity(AccountId accountId, EditIdentityRequest editIdentityRequest) async {
    final setIdentityMethod = SetIdentityMethod(accountId)
      ..addUpdates({
        editIdentityRequest.identityId.id : PatchObject(editIdentityRequest.identityRequest.toJson())
      });

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setIdentityInvocation = requestBuilder.invocation(setIdentityMethod);

    final response = await (requestBuilder
          ..usings(setIdentityMethod.requiredCapabilities))
        .build()
        .execute();

    final setIdentityResponse = response.parse<SetIdentityResponse>(
        setIdentityInvocation.methodCallId,
        SetIdentityResponse.deserialize);

    return Future.sync(() async {
      return setIdentityResponse?.updated?.containsKey(editIdentityRequest.identityId.id) == true;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<TMailRule>> getListTMailRule(AccountId accountId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getRuleFilterMethod = GetRuleFilterMethod(
        accountId,
    )..addIds({RuleFilterIdSingleton.ruleFilterIdSingleton.id});

    final getRuleFilterInvocation = requestBuilder.invocation(getRuleFilterMethod);
    final response = await (requestBuilder
        ..usings(getRuleFilterMethod.requiredCapabilities))
      .build()
      .execute();

    final result = response.parse<GetRuleFilterResponse>(
        getRuleFilterInvocation.methodCallId,
        GetRuleFilterResponse.deserialize);

    if (result?.list.isEmpty == true) {
      return <TMailRule>[];
    }

    return result?.list.first.rules ?? <TMailRule>[];
  }

  Future<List<TMailRule>> updateListTMailRule(AccountId accountId, List<TMailRule> listTMailRule) async {

    final newListTMailRuleWithIds = listTMailRule.withIds;

    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final setRuleFilterMethod = SetRuleFilterMethod(accountId)
      ..addUpdateRuleFilter({Id(RuleFilterIdType.singleton.value): newListTMailRuleWithIds});

    requestBuilder.invocation(setRuleFilterMethod);

    final getListTMailRuleUpdated = GetRuleFilterMethod(accountId)
      ..addIds({RuleFilterIdSingleton.ruleFilterIdSingleton.id});

    final getListTMailRuleUpdatedInvocation = requestBuilder.invocation(getListTMailRuleUpdated);

    final response = await (requestBuilder
        ..usings(getListTMailRuleUpdated.requiredCapabilities))
      .build()
      .execute();


    final result = response.parse<GetRuleFilterResponse>(
        getListTMailRuleUpdatedInvocation.methodCallId,
        GetRuleFilterResponse.deserialize);

    if (result?.list.isEmpty == true) {
      return <TMailRule>[];
    }

    return result?.list.first.rules ?? <TMailRule>[];
  }

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