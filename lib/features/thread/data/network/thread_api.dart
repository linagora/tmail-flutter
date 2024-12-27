import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/response/response_object.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/changes/changes_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/changes/changes_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/empty_mailbox_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ThreadAPI with HandleSetErrorMixin {

  final HttpClient httpClient;

  ThreadAPI(this.httpClient);

  Future<EmailsResponse> getAllEmail(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final queryEmailMethod = QueryEmailMethod(accountId);

    if (limit != null) queryEmailMethod.addLimit(limit);

    if (position != null) queryEmailMethod.addPosition(position);

    if (sort != null) queryEmailMethod.addSorts(sort);

    if (filter != null) queryEmailMethod.addFilters(filter);

    final queryEmailInvocation = jmapRequestBuilder.invocation(queryEmailMethod);

    final getEmailMethod = GetEmailMethod(accountId);

    if (properties != null) getEmailMethod.addProperties(properties);

    getEmailMethod.addReferenceIds(processingInvocation.createResultReference(
      queryEmailInvocation.methodCallId,
      ReferencePath.idsPath));

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final responseOfGetEmailMethod = result.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize,
    );

    final responseOfQueryEmailMethod = result.parse<QueryEmailResponse>(
      queryEmailInvocation.methodCallId,
      QueryEmailResponse.deserialize,
    );

    List<Email>? emailList;

    if (responseOfGetEmailMethod?.list.isNotEmpty == true &&
        responseOfQueryEmailMethod?.ids.isNotEmpty == true) {
      log('ThreadAPI::getAllEmail: QUERY_EMAIL_IDS = ${responseOfQueryEmailMethod?.ids}');
      final listSortedEmail = responseOfGetEmailMethod!.list
        .sortingByOrderOfIdList(responseOfQueryEmailMethod!.ids.toList());
      emailList = listSortedEmail;
    } else {
      emailList = responseOfGetEmailMethod?.list;
    }
    log('ThreadAPI::getAllEmail: EMAIL_DISPLAYED_IDS = ${emailList?.listEmailIds}');
    return EmailsResponse(
      emailList: emailList,
      state: responseOfGetEmailMethod?.state,
    );
  }

  Future<SearchEmailsResponse> searchEmails(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    // Email/query
    final queryEmailMethod = QueryEmailMethod(accountId);

    if (limit != null) queryEmailMethod.addLimit(limit);

    if (position != null) queryEmailMethod.addPosition(position);

    if (sort != null) queryEmailMethod.addSorts(sort);

    if (filter != null) queryEmailMethod.addFilters(filter);

    final queryEmailInvocation = jmapRequestBuilder.invocation(queryEmailMethod);

    // SearchSnippet/get
    final getSearchSnippetMethod = SearchSnippetGetMethod(accountId);
    if (filter != null) getSearchSnippetMethod.addFilters(filter);
    getSearchSnippetMethod.addReferenceEmailIds(
      processingInvocation.createResultReference(
        queryEmailInvocation.methodCallId,
        ReferencePath.idsPath));
    final getSearchSnippetInvocation = jmapRequestBuilder.invocation(
      getSearchSnippetMethod);

    // Email/get
    final getEmailMethod = GetEmailMethod(accountId);

    if (properties != null) getEmailMethod.addProperties(properties);

    getEmailMethod.addReferenceIds(processingInvocation.createResultReference(
      queryEmailInvocation.methodCallId,
      ReferencePath.idsPath));

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final emailResultList = result.parse<GetEmailResponse>(
        getEmailInvocation.methodCallId, GetEmailResponse.deserialize);
    final responseOfQueryEmailMethod = result.parse<QueryEmailResponse>(
      queryEmailInvocation.methodCallId,
      QueryEmailResponse.deserialize);

    List<Email>? sortedEmailList;

    if (emailResultList?.list.isNotEmpty == true &&
        responseOfQueryEmailMethod?.ids.isNotEmpty == true) {
      sortedEmailList = emailResultList!.list
        .sortingByOrderOfIdList(responseOfQueryEmailMethod!.ids.toList());
    } else {
      sortedEmailList = emailResultList?.list;
    }

    final searchSnippets = _getSearchSnippetsFromResponse(
      result,
      getSearchSnippetMethodCallId: getSearchSnippetInvocation.methodCallId,
    );
    return SearchEmailsResponse(
        emailList: sortedEmailList,
        state: emailResultList?.state,
        searchSnippets: searchSnippets);
  }

  List<SearchSnippet>? _getSearchSnippetsFromResponse(
    ResponseObject response,
    {required MethodCallId getSearchSnippetMethodCallId}
  ) {
    try {
      return response.parse<SearchSnippetGetResponse>(
          getSearchSnippetMethodCallId,
          SearchSnippetGetResponse.fromJson)?.list;
    } catch (e) {
      logError('ThreadAPI::searchEmails:getSearchSnippetsFromResponse: Exception = $e');
      return null;
    }
  }

  Future<EmailChangeResponse> getChanges(
    Session session,
    AccountId accountId,
    State sinceState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final changesEmailMethod = ChangesEmailMethod(accountId, sinceState, maxChanges: UnsignedInt(128));

    final changesEmailInvocation = jmapRequestBuilder.invocation(changesEmailMethod);

    final getMailboxUpdated = GetEmailMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesEmailInvocation.methodCallId,
          ReferencePath.updatedPath));

    if (propertiesUpdated != null) {
      getMailboxUpdated.addProperties(propertiesUpdated);
    }

    final getEmailCreated = GetEmailMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesEmailInvocation.methodCallId,
          ReferencePath.createdPath));

    if (propertiesCreated != null) {
      getEmailCreated.addProperties(propertiesCreated);
    }

    final getEmailUpdatedInvocation = jmapRequestBuilder.invocation(getMailboxUpdated);
    final getEmailCreatedInvocation = jmapRequestBuilder.invocation(getEmailCreated);

    final capabilities = getEmailCreated.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultChanges = result.parse<ChangesEmailResponse>(
      changesEmailInvocation.methodCallId,
      ChangesEmailResponse.deserialize);

    final resultUpdated = result.parse<GetEmailResponse>(
      getEmailUpdatedInvocation.methodCallId,
      GetEmailResponse.deserialize);

    final resultCreated = result.parse<GetEmailResponse>(
      getEmailCreatedInvocation.methodCallId,
      GetEmailResponse.deserialize);

    final listMailboxIdDestroyed = resultChanges?.destroyed.map((id) => EmailId(id)).toList() ?? <EmailId>[];

    return EmailChangeResponse(
      updated: resultUpdated?.list,
      created: resultCreated?.list,
      destroyed: listMailboxIdDestroyed,
      newStateEmail: resultUpdated?.state,
      newStateChanges: resultChanges?.newState,
      hasMoreChanges: resultChanges?.hasMoreChanges ?? false,
      updatedProperties: propertiesUpdated);
  }

  Future<Email> getEmailById(Session session, AccountId accountId, EmailId emailId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();
    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds({emailId.id});

    if (properties != null) {
      getEmailMethod.addProperties(properties);
    }

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultList = result.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize);

    return resultList!.list.first;
  }

  Future<EmptyMailboxResponse> deleteEmailsBaseOnQuery(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
    }
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final queryEmailMethod = QueryEmailMethod(accountId);

    if (limit != null) queryEmailMethod.addLimit(limit);

    if (position != null) queryEmailMethod.addPosition(position);

    if (sort != null) queryEmailMethod.addSorts(sort);

    if (filter != null) queryEmailMethod.addFilters(filter);

    final queryEmailInvocation = jmapRequestBuilder.invocation(queryEmailMethod);

    final setEmailMethod = SetEmailMethod(accountId);

    setEmailMethod.addReferenceDestroy(processingInvocation.createResultReference(
      queryEmailInvocation.methodCallId,
      ReferencePath.idsPath
    ));

    final setEmailInvocation = jmapRequestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities;

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final queryResponse = result.parse<QueryEmailResponse>(
      queryEmailInvocation.methodCallId, 
      QueryEmailResponse.deserialize  
    );

    final setEmailResponse = result.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId, 
      SetEmailResponse.deserialize
    );

    final destroyed = setEmailResponse?.destroyed
      ?.map((id) => EmailId(id));
    
    final queriedCount = queryResponse?.ids.length ?? 0;
    final destroyedCount = destroyed?.length ?? 0;
    
    if (destroyedCount < queriedCount) {
      final notFoundErrorCounter = _countingNotFoundInNotDestroy(setEmailResponse);
      final isSuccess = destroyedCount + notFoundErrorCounter >= queriedCount;
      return EmptyMailboxResponse(isSuccess, destroyedCount + notFoundErrorCounter);
    }
    return EmptyMailboxResponse(true, destroyedCount);
  }

  int _countingNotFoundInNotDestroy(SetEmailResponse? setEmailResponse) {
    int notFoundCount = 0;
    final notDestroyedHandlers = <SetMethodErrorHandler>{
      (entry) {
        if (entry.value.type == SetError.notFound) {
          notFoundCount++;
          return true;
        }
        return false;
      }
    };

    handleSetErrors(
      notDestroyedError: setEmailResponse?.notDestroyed,
      notDestroyedHandlers: notDestroyedHandlers
    );
    
    log('ThreadAPI::_countingNotFoundInNotDestroy: NOT_FOUND_ERRORS_COUNT = $notFoundCount');
    return notFoundCount;
  }
}