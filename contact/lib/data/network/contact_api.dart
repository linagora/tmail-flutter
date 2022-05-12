
import 'package:contact/contact/autocomplete/autocomplete_tmail_contact_method.dart';
import 'package:contact/contact/autocomplete/autocomplete_tmail_contact_response.dart';
import 'package:contact/contact/model/contact_filter.dart';
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

class ContactAPI {

  final HttpClient _httpClient;

  ContactAPI(this._httpClient);

  Future<List<TMailContact>> getAutoComplete(AccountId accountId, String word, {int? limit}) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final autoCompleteMethod = AutoCompleteTMailContactMethod(accountId, ContactFilter(word));

    final autoCompleteInvocation = requestBuilder.invocation(autoCompleteMethod);
    final response = await (requestBuilder
        ..usings(autoCompleteMethod.requiredCapabilities))
      .build()
      .execute();

    final result = response.parse<AutoCompleteTMailContactResponse>(
        autoCompleteInvocation.methodCallId,
        AutoCompleteTMailContactResponse.deserialize);

    return result?.list ?? <TMailContact>[];
  }
}