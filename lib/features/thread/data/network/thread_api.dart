import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
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
import 'package:model/extensions/list_id_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_response.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ThreadAPI {

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

    final emailList = sortEmails(
      getEmailResponse: responseOfGetEmailMethod,
      queryEmailResponse: responseOfQueryEmailMethod,
    );

    final notFoundEmailIds = responseOfGetEmailMethod
      ?.notFound
      ?.toEmailIds()
      .toList();
    log('ThreadAPI::getAllEmail:notFoundEmailIds = $notFoundEmailIds');
    return EmailsResponse(
      emailList: emailList,
      notFoundEmailIds: notFoundEmailIds,
      state: responseOfGetEmailMethod?.state,
    );
  }

  List<Email>? sortEmails({
    GetEmailResponse? getEmailResponse,
    QueryEmailResponse? queryEmailResponse,
  }) {
    final listEmails = getEmailResponse?.list;
    final listIds = queryEmailResponse?.ids.toList();

    if (listEmails?.isNotEmpty != true || listIds?.isNotEmpty != true) {
      return listEmails;
    }

    final listSortedEmails = listEmails!.sortEmailsById(listIds!);

    return listSortedEmails;
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

    final responseOfGetEmailMethod = result.parse<GetEmailResponse>(
        getEmailInvocation.methodCallId, GetEmailResponse.deserialize);
    final responseOfQueryEmailMethod = result.parse<QueryEmailResponse>(
      queryEmailInvocation.methodCallId,
      QueryEmailResponse.deserialize);

    final sortedEmailList = sortEmails(
      getEmailResponse: responseOfGetEmailMethod,
      queryEmailResponse: responseOfQueryEmailMethod,
    );

    final searchSnippets = _getSearchSnippetsFromResponse(
      result,
      getSearchSnippetMethodCallId: getSearchSnippetInvocation.methodCallId,
    );
    return SearchEmailsResponse(
        emailList: sortedEmailList,
        state: responseOfGetEmailMethod?.state,
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

    GetEmailMethod? getEmailUpdated;
    GetEmailMethod? getEmailCreated;
    RequestInvocation? getEmailUpdatedInvocation;
    RequestInvocation? getEmailCreatedInvocation;

    if (propertiesUpdated != null) {
      getEmailUpdated = GetEmailMethod(accountId)
        ..addReferenceIds(
            processingInvocation.createResultReference(
              changesEmailInvocation.methodCallId,
              ReferencePath.updatedPath,
            ),
          )
        ..addProperties(propertiesUpdated);

      getEmailUpdatedInvocation = jmapRequestBuilder.invocation(getEmailUpdated);
    }

    if (propertiesCreated != null) {
      getEmailCreated = GetEmailMethod(accountId)
        ..addReferenceIds(
            processingInvocation.createResultReference(
              changesEmailInvocation.methodCallId,
              ReferencePath.createdPath,
            ),
          )
        ..addProperties(propertiesCreated);

      getEmailCreatedInvocation = jmapRequestBuilder.invocation(getEmailCreated);
    }

    final requiredCapabilitiesMethod = getEmailCreated?.requiredCapabilities
      ?? getEmailUpdated?.requiredCapabilities
      ?? changesEmailMethod.requiredCapabilities;

    final usedCapabilities = requiredCapabilitiesMethod
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(usedCapabilities))
      .build()
      .execute();

    final resultChanges = result.parse<ChangesEmailResponse>(
      changesEmailInvocation.methodCallId,
      ChangesEmailResponse.deserialize);

    List<EmailId> destroyedEmailIds = resultChanges
      ?.destroyed
      .toEmailIds()
      .toList() ?? [];
    State? newStateChanges = resultChanges?.newState;
    bool hasMoreChanges = resultChanges?.hasMoreChanges ?? false;
    List<Email>? updatedEmail;
    List<Email>? createdEmail;
    State? newStateEmail;

    if (getEmailUpdatedInvocation != null) {
      final emailResponseUpdated = result.parse<GetEmailResponse>(
        getEmailUpdatedInvocation.methodCallId,
        GetEmailResponse.deserialize,
      );
      updatedEmail = emailResponseUpdated?.list;
      newStateEmail = emailResponseUpdated?.state;
      final notFoundIdsUpdated = emailResponseUpdated?.notFound?.toEmailIds().toList() ?? [];
      log('ThreadAPI::getChanges:notFoundIdsUpdated = $notFoundIdsUpdated');
      destroyedEmailIds.addAll(notFoundIdsUpdated);
    }

    if (getEmailCreatedInvocation != null) {
      final emailResponseCreated = result.parse<GetEmailResponse>(
        getEmailCreatedInvocation.methodCallId,
        GetEmailResponse.deserialize,
      );
      createdEmail = emailResponseCreated?.list;
      newStateEmail = emailResponseCreated?.state;
      final notFoundIdsCreated = emailResponseCreated?.notFound?.toEmailIds().toList() ?? [];
      log('ThreadAPI::getChanges:notFoundIdsCreated = $notFoundIdsCreated');
      destroyedEmailIds.addAll(notFoundIdsCreated);
    }
    log('ThreadAPI::getChanges:newStateChanges = $newStateChanges | newStateEmail = $newStateEmail | hasMoreChanges = $hasMoreChanges');
    log('ThreadAPI::getChanges:updatedEmailSize = ${updatedEmail?.length} | createdEmailSize = ${createdEmail?.length}');
    log('ThreadAPI::getChanges:destroyedEmailIds = $destroyedEmailIds');
    return EmailChangeResponse(
      updated: updatedEmail,
      created: createdEmail,
      destroyed: destroyedEmailIds,
      newStateEmail: newStateEmail,
      newStateChanges: newStateChanges,
      hasMoreChanges: hasMoreChanges,
      updatedProperties: propertiesUpdated,
    );
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
}