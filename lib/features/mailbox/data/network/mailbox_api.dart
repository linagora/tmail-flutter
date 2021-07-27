import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MailboxAPI {

  final HttpClient httpClient;

  MailboxAPI(this.httpClient);

  Future<List<Mailbox>> getAllMailbox(AccountId accountId, {Properties? properties}) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getMailboxCreated = GetMailboxMethod(accountId);

    final queryInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..invocation(getMailboxCreated)
        ..usings(getMailboxCreated.requiredCapabilities))
      .build()
      .execute();

    final resultCreated = result.parse<GetMailboxResponse>(
      queryInvocation.methodCallId,
      GetMailboxResponse.deserialize);

    return resultCreated == null ? [] : resultCreated.list;
  }
}