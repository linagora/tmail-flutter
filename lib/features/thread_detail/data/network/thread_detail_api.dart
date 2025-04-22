import 'package:get/get_utils/get_utils.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/thread/get/get_thread_method.dart';
import 'package:jmap_dart_client/jmap/thread/get/get_thread_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class ThreadDetailApi {
  const ThreadDetailApi(this._httpClient);

  final HttpClient _httpClient;

  Future<List<EmailId>> getThread(
    ThreadId threadId,
    AccountId accountId,
  ) async {
    final requestBuilder = JmapRequestBuilder(
      _httpClient,
      ProcessingInvocation(),
    );
    final getThreadMethod = GetThreadMethod(accountId)
      ..addIds({threadId.id});
    final getThreadInvocation = requestBuilder.invocation(getThreadMethod);
    final response = await (requestBuilder..usings(getThreadMethod.requiredCapabilities))
      .build()
      .execute();
    final getThreadResponse = response.parse<GetThreadResponse>(
      getThreadInvocation.methodCallId,
      GetThreadResponse.deserialize,
    );

    return getThreadResponse?.list.firstWhereOrNull(
      (thread) => thread.id == threadId,
    )?.emailIds ?? [];
  }

  Future<List<Email>> getEmailsByIds(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds, {
    Properties? properties,
  }) async {
    final jmapRequestBuilder = JmapRequestBuilder(
      _httpClient,
      ProcessingInvocation(),
    );

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds(emailIds.map((emailId) => emailId.id).toSet());

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

    return resultList!.list;
  }
}