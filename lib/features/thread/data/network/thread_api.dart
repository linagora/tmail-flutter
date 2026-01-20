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
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_response.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_id_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ThreadAPI with HandleSetErrorMixin, MailAPIMixin {

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
    return await fetchAllEmail(
      httpClient: httpClient,
      session: session,
      accountId: accountId,
      limit: limit,
      position: position,
      sort: sort,
      filter: filter,
      properties: properties,
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
      logWarning('ThreadAPI::searchEmails:getSearchSnippetsFromResponse: Exception = $e');
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
    // Step 1: Call Email/changes to get the list of changed IDs
    final changesResult = await _getEmailChangesOnly(session, accountId, sinceState);

    final List<EmailId> createdIds = changesResult.created.toEmailIds().toList();
    final List<EmailId> updatedIds = changesResult.updated.toEmailIds().toList();
    List<EmailId> destroyedEmailIds = changesResult.destroyed.toEmailIds().toList();
    final State? newStateChanges = changesResult.newState;
    final bool hasMoreChanges = changesResult.hasMoreChanges;

    log('ThreadAPI::getChanges:createdIds = ${createdIds.length} | updatedIds = ${updatedIds.length} | destroyedIds = ${destroyedEmailIds.length}');

    // Step 2: Batch fetch emails respecting maxObjectsInGet limit
    List<Email>? updatedEmail;
    List<Email>? createdEmail;
    State? newStateEmail;

    if (propertiesUpdated != null && updatedIds.isNotEmpty) {
      final result = await getEmailsByIdsBatched(
        httpClient: httpClient,
        session: session,
        accountId: accountId,
        emailIds: updatedIds,
        properties: propertiesUpdated,
      );
      updatedEmail = result.emails;
      newStateEmail = result.state;
      final notFoundIds = result.notFoundIds;
      log('ThreadAPI::getChanges:notFoundIdsUpdated = $notFoundIds');
      if (notFoundIds.isNotEmpty) {
        destroyedEmailIds.addAll(notFoundIds);
        log('ThreadAPI::getChanges:notFoundIdsUpdated = ${notFoundIds.asListString.toString()} | SinceState = ${sinceState.value}');
      }
    }

    if (propertiesCreated != null && createdIds.isNotEmpty) {
      final result = await getEmailsByIdsBatched(
        httpClient: httpClient,
        session: session,
        accountId: accountId,
        emailIds: createdIds,
        properties: propertiesCreated,
      );
      createdEmail = result.emails;
      newStateEmail = result.state;
      final notFoundIds = result.notFoundIds;
      log('ThreadAPI::getChanges:notFoundIdsCreated = $notFoundIds');
      if (notFoundIds.isNotEmpty) {
        destroyedEmailIds.addAll(notFoundIds);
        log('ThreadAPI::getChanges:notFoundIdsCreated = ${notFoundIds.asListString.toString()} | SinceState = ${sinceState.value}');
      }
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

  Future<ChangesEmailResponse> _getEmailChangesOnly(
    Session session,
    AccountId accountId,
    State sinceState,
  ) async {
    final processingInvocation = ProcessingInvocation();
    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final changesEmailMethod = ChangesEmailMethod(accountId, sinceState);
    final changesEmailInvocation = jmapRequestBuilder.invocation(changesEmailMethod);

    final capabilities = changesEmailMethod.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultChanges = result.parse<ChangesEmailResponse>(
      changesEmailInvocation.methodCallId,
      ChangesEmailResponse.deserialize);

    return resultChanges!;
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