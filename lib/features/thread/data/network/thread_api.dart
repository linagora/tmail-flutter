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
import 'package:jmap_dart_client/jmap/thread/get/get_thread_method.dart';
import 'package:jmap_dart_client/jmap/thread/get/get_thread_response.dart';
import 'package:jmap_dart_client/jmap/thread/thread.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/list_id_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet_get_response.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/get_email_method_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_id_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/query_email_method_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/reference_path_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/search_snippet_get_method_extension.dart';
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
    AccountId accountId, {
    UnsignedInt? limit,
    int? position,
    Set<Comparator>? sort,
    Filter? filter,
    bool? collapseThreads,
    Properties? properties,
  }) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    /// QueryEmail
    final queryEmail = QueryEmailMethod(accountId)
      ..addLimitIfNotNull(limit)
      ..addPositionIfValid(position)
      ..addSortsIfNotNull(sort)
      ..addFiltersIfNotNull(filter)
      ..addCollapseThreadsIfNotNull(collapseThreads);

    final queryInvocation = requestBuilder.invocation(queryEmail);

    /// SearchSnippet/get
    final searchSnippetMethod = SearchSnippetGetMethod(accountId)
      ..addFiltersIfNotNull(filter)
      ..addReferenceEmailIds(
        processingInvocation.createResultReference(
          queryInvocation.methodCallId,
          ReferencePath.idsPath,
        ),
      );

    final searchSnippetInvocation =
        requestBuilder.invocation(searchSnippetMethod);

    /// Email/get
    if (collapseThreads == true) {
      properties ??= Properties({EmailProperty.threadId});
      properties.value.add(EmailProperty.threadId);
    }

    final getEmail = GetEmailMethod(accountId)
      ..addPropertiesIfNotNull(properties)
      ..addReferenceIds(
        processingInvocation.createResultReference(
          queryInvocation.methodCallId,
          ReferencePath.idsPath,
        ),
      );

    final getEmailInvocation = requestBuilder.invocation(getEmail);

    /// Optional Thread/get
    MethodCallId? getThreadMethodCallId;

    if (collapseThreads == true) {
      final getThread = GetThreadMethod(accountId)
        ..addReferenceIds(
          processingInvocation.createResultReference(
            getEmailInvocation.methodCallId,
            ReferencePathExtension.listThreadIdsPath,
          ),
        );

      getThreadMethodCallId = requestBuilder.invocation(getThread).methodCallId;
    }

    /// Execute request
    final capabilities = getEmail.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result =
        await (requestBuilder..usings(capabilities)).build().execute();

    /// Parse Email + Query
    final getEmailResponse = result.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize,
    );

    final queryEmailResponse = result.parse<QueryEmailResponse>(
      queryInvocation.methodCallId,
      QueryEmailResponse.deserialize,
    );

    final sortedEmailList = sortEmails(
      getEmailResponse: getEmailResponse,
      queryEmailResponse: queryEmailResponse,
    );

    /// Parse snippets
    final searchSnippets = _getSearchSnippetsFromResponse(
      result,
      getSearchSnippetMethodCallId: searchSnippetInvocation.methodCallId,
    );

    /// Parse threads (optional)
    final threadLists = getThreadMethodCallId != null
        ? _parseThreadListFromResponse(
            response: result,
            methodCallId: getThreadMethodCallId,
          )
        : null;

    return SearchEmailsResponse(
      emailList: sortedEmailList,
      state: getEmailResponse?.state,
      searchSnippets: searchSnippets,
      threadLists: threadLists,
    );
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

  List<Thread>? _parseThreadListFromResponse({
    required ResponseObject response,
    required MethodCallId methodCallId,
  }) {
    try {
      return response.parse<GetThreadResponse>(
        methodCallId,
        GetThreadResponse.deserialize,
      )?.list;
    } catch (e) {
      logWarning('ThreadAPI::_parseThreadListFromResponse: Exception = $e');
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
      if (notFoundIdsUpdated.isNotEmpty) {
        destroyedEmailIds.addAll(notFoundIdsUpdated);
        log('ThreadAPI::getChanges:notFoundIdsUpdated = ${notFoundIdsUpdated.asListString.toString()} | SinceState = ${sinceState.value}');
      }
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
      if (notFoundIdsCreated.isNotEmpty) {
        destroyedEmailIds.addAll(notFoundIdsCreated);
        log('ThreadAPI::getChanges:notFoundIdsCreated = ${notFoundIdsCreated.asListString.toString()} | SinceState = ${sinceState.value}');
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