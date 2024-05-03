import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/changes/changes_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/changes/changes_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
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

    final resultList = result.parse<GetEmailResponse>(
        getEmailInvocation.methodCallId, GetEmailResponse.deserialize);

    if (sort != null && resultList != null) {
      for (var comparator in sort) {
        resultList.sortEmails(comparator);
      }
    }

    return EmailsResponse(emailList: resultList?.list, state: resultList?.state);
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

  Future<dartz.Tuple2<List<EmailId>, List<EmailId>>> deleteAllPermanentlyEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final queryEmailMethod = QueryEmailMethod(accountId)
      ..addLimit(UnsignedInt(30))
      ..addFilters(EmailFilterCondition(inMailbox: mailboxId))
      ..addSorts(<Comparator>{}..add(
          EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(false)
      ));

    final queryEmailInvocation = jmapRequestBuilder.invocation(queryEmailMethod);

    final setEmailMethod = SetEmailMethod(accountId)
      ..addReferenceDestroy(
        processingInvocation.createResultReference(
          queryEmailInvocation.methodCallId,
          ReferencePath.idsPath
        )
      );

    final setEmailInvocation = jmapRequestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder..usings(capabilities))
      .build()
      .execute();

    final queryEmailResponse = result.parse<QueryEmailResponse>(
      queryEmailInvocation.methodCallId,
      QueryEmailResponse.deserialize);

    final setEmailResponse = result.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize);

    final listMatchedEmailId = queryEmailResponse?.ids.map((id) => EmailId(id)).toList() ?? [];
    final listDeletedEmailId = setEmailResponse?.destroyed?.map((id) => EmailId(id)).toList() ?? [];
    log('ThreadAPI::deleteAllPermanentlyEmails:listMatchedEmailId = $listMatchedEmailId');
    log('ThreadAPI::deleteAllPermanentlyEmails:listDeletedEmailId = $listDeletedEmailId');
    return dartz.Tuple2(listMatchedEmailId, listDeletedEmailId);
  }
}