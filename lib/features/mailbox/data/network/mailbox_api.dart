import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart' as JmapHttpClient;
import 'package:jmap_dart_client/jmap/core/properties/properties.dart' as JmapProperties;
import 'package:jmap_dart_client/jmap/account_id.dart' as JmapAccountId;
import 'package:jmap_dart_client/jmap/jmap_request.dart' as JmapRequest;
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart' as JmapGetMailboxMethod;
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart' as JmapGetMailboxResponse;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JmapMailbox;

class MailboxAPI {

  final JmapHttpClient.HttpClient httpClient;

  MailboxAPI(this.httpClient);

  Future<List<JmapMailbox.Mailbox>> getAllMailbox(JmapAccountId.AccountId accountId, {JmapProperties.Properties? properties}) async {
    final processingInvocation = JmapRequest.ProcessingInvocation();

    final jmapRequestBuilder = JmapRequest.JmapRequestBuilder(httpClient, processingInvocation);

    final getMailboxCreated = JmapGetMailboxMethod.GetMailboxMethod(accountId);

    final queryInvocation = jmapRequestBuilder.invocation(getMailboxCreated);

    final result = await (jmapRequestBuilder
        ..invocation(getMailboxCreated)
        ..usings(getMailboxCreated.requiredCapabilities))
      .build()
      .execute();

    final resultCreated = result.parse<JmapGetMailboxResponse.GetMailboxResponse>(
      queryInvocation.methodCallId,
      JmapGetMailboxResponse.GetMailboxResponse.deserialize);


    return resultCreated == null ? [] : resultCreated.list;
  }
}