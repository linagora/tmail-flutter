import 'dart:math' hide log;

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:labels/method/get/get_label_method.dart';
import 'package:labels/method/get/get_label_response.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/session_mixin.dart';

mixin BatchGetLabelProcessingMixin on HandleSetErrorMixin, SessionMixin {
  Future<
      ({
        List<Label> labels,
        List<Id> notFoundIds,
        State? state,
      })> executeBatchGetLabel({
    required Session session,
    required AccountId accountId,
    required List<Id> labelIds,
    required HttpClient httpClient,
    String debugLabel = 'executeBatchGetLabel',
  }) async {
    if (labelIds.isEmpty) {
      return (labels: <Label>[], notFoundIds: <Id>[], state: null);
    }

    final maxObjects = getMaxObjectsInGetMethod(session, accountId);
    final totalLabels = labelIds.length;
    final batchSize = max(1, min(totalLabels, maxObjects));

    final List<Label> allLabels = [];
    final List<Id> allNotFoundIds = [];
    State? latestState;

    for (int start = 0; start < totalLabels; start += batchSize) {
      int end =
          (start + batchSize < totalLabels) ? start + batchSize : totalLabels;
      final currentListIds = labelIds.sublist(start, end);

      log('BatchGetLabelProcessingMixin::$debugLabel: processing batch ${start + 1} to $end');

      try {
        final response = await _executeGetLabelBatch(
          accountId: accountId,
          httpClient: httpClient,
          labelIds: currentListIds,
        );

        if (response == null) {
          throw Exception('GetLabelResponse is null');
        }

        if (response.list.isNotEmpty) {
          allLabels.addAll(response.list);
        }

        latestState = response.state;

        final notFoundIds = response.notFound ?? [];
        if (notFoundIds.isNotEmpty) {
          allNotFoundIds.addAll(notFoundIds);
        }
      } catch (e) {
        logWarning(
          'BatchGetLabelProcessingMixin::$debugLabel: Error processing batch ${start + 1}-$end: $e',
        );
      }
    }

    return (labels: allLabels, notFoundIds: allNotFoundIds, state: latestState);
  }

  Future<GetLabelResponse?> _executeGetLabelBatch({
    required AccountId accountId,
    required HttpClient httpClient,
    required List<Id> labelIds,
  }) async {
    final getLabelMethod = GetLabelMethod(accountId)..addIds(labelIds.toSet());

    final requestBuilder = JmapRequestBuilder(
      httpClient,
      ProcessingInvocation(),
    );

    final invocation = requestBuilder.invocation(getLabelMethod);

    final response = await (requestBuilder
          ..usings(getLabelMethod.requiredCapabilities))
        .build()
        .execute();

    return response.parse<GetLabelResponse>(
      invocation.methodCallId,
      GetLabelResponse.deserialize,
    );
  }
}
