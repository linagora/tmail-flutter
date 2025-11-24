import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:labels/labels.dart';

class LabelApi {
  final HttpClient _httpClient;

  LabelApi(this._httpClient);

  Future<List<Label>> getAllLabels(AccountId accountId) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = GetLabelMethod(accountId);
    final invocation = builder.invocation(method);

    final result =
        await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<GetLabelResponse>(
      invocation.methodCallId,
      GetLabelResponse.deserialize,
    );

    return response?.list ?? [];
  }
}
