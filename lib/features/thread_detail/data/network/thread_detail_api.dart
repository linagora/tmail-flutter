import 'package:get/get_utils/get_utils.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/thread/get/get_thread_method.dart';
import 'package:jmap_dart_client/jmap/thread/get/get_thread_response.dart';

class ThreadDetailApi {
  const ThreadDetailApi(this._httpClient);

  final HttpClient _httpClient;

  Future<List<EmailId>> getThreadById(
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

    return getThreadResponse!.list.firstWhereOrNull(
      (thread) => thread.id == threadId,
    )!.emailIds;
  }
}