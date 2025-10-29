import 'dart:async';
import 'dart:math' hide log;

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
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
import 'package:model/email/email_property.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:model/extensions/list_email_id_extension.dart';
import 'package:model/extensions/list_id_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_id_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

mixin MailAPIMixin on HandleSetErrorMixin {
  int getMaxObjectsInSetMethod(Session session, AccountId accountId) {
    final coreCapability = session.getCapabilityProperties<CoreCapability>(
      accountId,
      CapabilityIdentifier.jmapCore,
    );
    final maxObjectsInSetMethod =
        coreCapability?.maxObjectsInSet?.value.toInt() ??
            CapabilityIdentifierExtension.defaultMaxObjectsInSet;

    final minOfMaxObjectsInSetMethod = min(
      maxObjectsInSetMethod,
      CapabilityIdentifierExtension.defaultMaxObjectsInSet,
    );
    log('$runtimeType::_getMaxObjectsInSetMethod:minOfMaxObjectsInSetMethod = $minOfMaxObjectsInSetMethod');
    return minOfMaxObjectsInSetMethod;
  }

  Future<({List<EmailId> emailIdsSuccess, Map<Id, SetError> mapErrors})>
      moveEmailsBetweenMailboxes({
    required HttpClient httpClient,
    required Session session,
    required AccountId accountId,
    required List<EmailId> emailIds,
    required MailboxId currentMailboxId,
    required MailboxId destinationMailboxId,
    bool markAsRead = false,
  }) async {
    final maxObjects = getMaxObjectsInSetMethod(session, accountId);
    final totalEmails = emailIds.length;
    final maxBatches = min(totalEmails, maxObjects);

    final List<EmailId> updatedEmailIds = List.empty(growable: true);
    final Map<Id, SetError> mapErrors = <Id, SetError>{};

    for (int start = 0; start < totalEmails; start += maxBatches) {
      int end =
          (start + maxBatches < totalEmails) ? start + maxBatches : totalEmails;
      log('$runtimeType::moveEmailsBetweenMailboxes:emails from ${start + 1} to $end');

      final currentEmailIds = emailIds.sublist(start, end);

      final moveProperties = currentEmailIds.generateMapUpdateObjectMoveToMailbox(
        currentMailboxId: currentMailboxId,
        destinationMailboxId: destinationMailboxId,
        markAsRead: markAsRead,
      );

      final setEmailMethod = SetEmailMethod(accountId)
        ..addUpdates(moveProperties);

      final requestBuilder =
          JmapRequestBuilder(httpClient, ProcessingInvocation());

      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response =
          await (requestBuilder..usings(capabilities)).build().execute();

      final setEmailResponse = response.parse(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize,
      );

      final listEmailIds = setEmailResponse?.updated?.keys.toEmailIds() ?? [];
      final mapErrors = handleSetResponse([setEmailResponse]);

      updatedEmailIds.addAll(listEmailIds);
      mapErrors.addAll(mapErrors);
    }

    return (emailIdsSuccess: updatedEmailIds, mapErrors: mapErrors);
  }

  Future<EmailsResponse> fetchAllEmail({
    required HttpClient httpClient,
    required Session session,
    required AccountId accountId,
    UnsignedInt? limit,
    int? position,
    Set<Comparator>? sort,
    Filter? filter,
    Properties? properties,
  }) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(
      httpClient,
      processingInvocation,
    );

    final queryEmailMethod = QueryEmailMethod(accountId);

    if (limit != null) queryEmailMethod.addLimit(limit);

    if (position != null) queryEmailMethod.addPosition(position);

    if (sort != null) queryEmailMethod.addSorts(sort);

    if (filter != null) queryEmailMethod.addFilters(filter);

    final queryEmailInvocation =
        jmapRequestBuilder.invocation(queryEmailMethod);

    final getEmailMethod = GetEmailMethod(accountId);

    if (properties != null) getEmailMethod.addProperties(properties);

    getEmailMethod.addReferenceIds(
      processingInvocation.createResultReference(
        queryEmailInvocation.methodCallId,
        ReferencePath.idsPath,
      ),
    );

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result =
        await (jmapRequestBuilder..usings(capabilities)).build().execute();

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

    final notFoundEmailIds =
        responseOfGetEmailMethod?.notFound?.toEmailIds().toList();
    log('$runtimeType::getAllEmail:notFoundEmailIds = ${notFoundEmailIds!.asListString.toString()} | NewState = ${responseOfGetEmailMethod?.state.value}');
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

  Future<void> moveAllEmailsBetweenFolders({
    required HttpClient httpClient,
    required Session session,
    required AccountId accountId,
    required MailboxId currentMailboxId,
    required MailboxId destinationMailboxId,
    required MoveAction moveAction,
    int totalEmails = 0,
    bool markAsRead = false,
    StreamController<Either<Failure, Success>>? onProgressController,
  }) async {
    int countEmailsCompleted = 0;
    bool hasEmails = true;
    Email? lastEmail;

    while (hasEmails) {
      final listEmails = await getLatestEmails(
        httpClient: httpClient,
        session: session,
        accountId: accountId,
        mailboxId: currentMailboxId,
        lastEmail: lastEmail,
      );
      log('$runtimeType::moveAllEmailsBetweenFolders(): Length of emails = ${listEmails.length}');
      if (listEmails.isEmpty) {
        hasEmails = false;
      } else {
        hasEmails = true;
        lastEmail = listEmails.last;

        final movedEmails = await moveEmailsBetweenMailboxes(
          httpClient: httpClient,
          session: session,
          accountId: accountId,
          emailIds: listEmails.listEmailIds,
          currentMailboxId: currentMailboxId,
          destinationMailboxId: destinationMailboxId,
          markAsRead: markAsRead,
        );

        countEmailsCompleted += movedEmails.emailIdsSuccess.length;

        onProgressController?.add(
          Right<Failure, Success>(MoveFolderContentProgressState(
            currentMailboxId,
            countEmailsCompleted,
            totalEmails,
          )),
        );
      }
    }
    log('$runtimeType::moveAllEmailsBetweenFolders(): Total emails moved = $countEmailsCompleted');
    if (moveAction == MoveAction.moving &&
        countEmailsCompleted < totalEmails &&
        totalEmails > 0) {
      throw CannotMoveAllEmailException();
    }
  }

  Future<List<Email>> getLatestEmails({
    required HttpClient httpClient,
    required Session session,
    required AccountId accountId,
    required MailboxId mailboxId,
    Email? lastEmail,
  }) async {
    final response = await fetchAllEmail(
      httpClient: httpClient,
      session: session,
      accountId: accountId,
      sort: <Comparator>{}..add(
        EmailComparator(
          EmailComparatorProperty.receivedAt,
        )..setIsAscending(false),
      ),
      filter: EmailFilterCondition(
        inMailbox: mailboxId,
        before: lastEmail?.receivedAt,
      ),
      properties: Properties({
        EmailProperty.id,
        EmailProperty.receivedAt,
      }),
    );

    if (lastEmail?.id != null) {
      return response.emailList?.withoutEmailWithId(lastEmail!.id!) ?? [];
    } else {
      return response.emailList ?? [];
    }
  }
}
