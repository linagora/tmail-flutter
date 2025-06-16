import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:rule_filter/ai_bot/suggestReply/suggest_reply_response.dart';
import 'package:rule_filter/ai_bot/suggestReply/suggest_reply_method.dart';

class SuggestReplyApi {
  final HttpClient _httpClient;
  SuggestReplyApi(this._httpClient);

  Future<SuggestReplyResponse?> suggestReply(
      {required AccountId accountId,
      required String userInput,
      String? mailId}) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder =
        JmapRequestBuilder(_httpClient, processingInvocation);

    final suggestReplyMethod = SuggestReplyMethod(
      accountId: accountId,
      emailId: mailId ?? '',
      userInput: userInput,
    );

    final aiBotSuggestInvocation =
        requestBuilder.invocation(suggestReplyMethod);

    final response = await (requestBuilder
          ..usings(suggestReplyMethod.requiredCapabilities))
        .build()
        .execute();

    final result = response.parse<SuggestReplyResponse>(
        aiBotSuggestInvocation.methodCallId, SuggestReplyResponse.deserialize);

    return result;
  }
}
