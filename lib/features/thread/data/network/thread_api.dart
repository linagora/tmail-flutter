import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';

class ThreadAPI {

  final HttpClient httpClient;

  ThreadAPI(this.httpClient);

  Future<List<Email>> getAllEmail(
    AccountId accountId,
    {
      int? position,
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final queryEmailMethod = QueryEmailMethod(accountId);

    if (position != null) queryEmailMethod..addPosition(position);

    if (limit != null) queryEmailMethod..addLimit(limit);

    if (sort != null) queryEmailMethod..addSorts(sort);

    if (filter != null) queryEmailMethod..addFilters(filter);

    final queryEmailInvocation = jmapRequestBuilder.invocation(queryEmailMethod);

    final getEmailMethod = GetEmailMethod(accountId);

    if (properties != null) getEmailMethod..addProperties(properties);

    getEmailMethod..addReferenceIds(processingInvocation.createResultReference(
      queryEmailInvocation.methodCallId,
      ReferencePath.idsPath));

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final result = await (jmapRequestBuilder
        ..usings(getEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final resultList = result.parse<GetEmailResponse>(
        getEmailInvocation.methodCallId, GetEmailResponse.deserialize);

    if (sort != null && resultList != null) {
      sort.forEach((comparator) {
        resultList..sortEmails(comparator);
      });
    }

    return resultList == null ? [] : resultList.list;
  }
}