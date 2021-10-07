import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/changes/changes_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/changes/changes_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';

class MailboxAPI {

  final HttpClient httpClient;

  MailboxAPI(this.httpClient);

  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getMailboxCreated = GetMailboxMethod(accountId);

    final queryInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..usings(getMailboxCreated.requiredCapabilities))
      .build()
      .execute();

    final resultCreated = result.parse<GetMailboxResponse>(
      queryInvocation.methodCallId,
      GetMailboxResponse.deserialize);

    return MailboxResponse(mailboxes: resultCreated?.list, state: resultCreated?.state);
  }

  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final changesMailboxMethod = ChangesMailboxMethod(accountId, sinceState, maxChanges: UnsignedInt(128));

    final changesMailboxInvocation = jmapRequestBuilder.invocation(changesMailboxMethod);

    final getMailboxUpdated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPath))
      ..addReferenceProperties(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.updatedPropertiesPath));

    final getMailboxCreated = GetMailboxMethod(accountId)
      ..addReferenceIds(processingInvocation.createResultReference(
          changesMailboxInvocation.methodCallId,
          ReferencePath.createdPath));

    final getMailboxUpdatedInvocation = jmapRequestBuilder.invocation(getMailboxUpdated);
    final getMailboxCreatedInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..usings(getMailboxCreated.requiredCapabilities))
      .build()
      .execute();

    final resultChanges = result.parse<ChangesMailboxResponse>(
        changesMailboxInvocation.methodCallId,
        ChangesMailboxResponse.deserialize);

    final resultUpdated = result.parse<GetMailboxResponse>(
        getMailboxUpdatedInvocation.methodCallId,
        GetMailboxResponse.deserialize);

    final resultCreated = result.parse<GetMailboxResponse>(
        getMailboxCreatedInvocation.methodCallId,
        GetMailboxResponse.deserialize);

    final listMailboxIdDestroyed = resultChanges?.destroyed.map((id) => MailboxId(id)).toList() ?? <MailboxId>[];

    return MailboxChangeResponse(
      updated: resultUpdated?.list,
      created: resultCreated?.list,
      destroyed: listMailboxIdDestroyed,
      newStateMailbox: resultUpdated?.state,
      newStateChanges: resultChanges?.newState,
      hasMoreChanges: resultChanges?.hasMoreChanges ?? false,
      updatedProperties: resultChanges?.updatedProperties);
  }
}