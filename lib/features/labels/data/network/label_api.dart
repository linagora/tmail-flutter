import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/base/mixin/batch_get_label_processing_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/session_mixin.dart';
import 'package:tmail_ui_user/features/labels/data/model/label_change_response.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:uuid/uuid.dart';

class LabelApi
    with HandleSetErrorMixin, SessionMixin, BatchGetLabelProcessingMixin {

  static const int _defaultMaxChanges = 128;

  final HttpClient _httpClient;
  final Uuid _uuid;

  LabelApi(this._httpClient, this._uuid);

  Future<({List<Label> labels, State? newState})> getAllLabels(AccountId accountId) async {
    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final method = GetLabelMethod(accountId);
    final invocation = builder.invocation(method);

    final result =
        await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<GetLabelResponse>(
      invocation.methodCallId,
      GetLabelResponse.deserialize,
    );

    return (labels: response?.list ?? [], newState: response?.state);
  }

  Future<Label> createNewLabel(AccountId accountId, Label labelData) async {
    final generateCreateId = Id(_uuid.v1());

    final method = SetLabelMethod(accountId)
      ..addCreate(generateCreateId, labelData);

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final result =
        await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<SetLabelResponse>(
      invocation.methodCallId,
      SetLabelResponse.deserialize,
    );

    final labelIdsCreated = response?.created?.keys ?? <Id>[];

    if (labelIdsCreated.contains(generateCreateId)) {
      final labelCreated = response?.created?[generateCreateId];
      final newLabelCreated = labelCreated!.copyWith(
        displayName: labelData.displayName,
        color: labelData.color,
      );
      return newLabelCreated;
    } else {
      throw parseErrorForSetResponse(response, generateCreateId);
    }
  }

  Future<Label> editLabel(
    AccountId accountId,
    EditLabelRequest labelRequest,
  ) async {
    final labelId = labelRequest.labelId;
    final newLabel = labelRequest.newLabel;

    final method = SetLabelMethod(accountId)
      ..addUpdates({
        labelId: PatchObject(newLabel.toJson())
      });

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final result =
        await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<SetLabelResponse>(
      invocation.methodCallId,
      SetLabelResponse.deserialize,
    );

    final labelIdsUpdated = response?.updated?.keys ?? <Id>[];

    if (labelIdsUpdated.contains(labelId)) {
      final newLabelUpdated = newLabel.copyWith(
        id: labelId,
        keyword: labelRequest.labelKeyword,
      );
      return newLabelUpdated;
    } else {
      throw parseErrorForSetResponse(response, labelId);
    }
  }

  Future<void> deleteLabel(AccountId accountId, Label label) async {
    final labelId = label.id;

    if (labelId == null) {
      throw LabelIdIsNull();
    }

    final method = SetLabelMethod(accountId)..addDestroy({labelId});

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final result =
        await (builder..usings(method.requiredCapabilities)).build().execute();

    final response = result.parse<SetLabelResponse>(
      invocation.methodCallId,
      SetLabelResponse.deserialize,
    );

    if (response?.destroyed?.contains(labelId) != true) {
      throw parseErrorForSetResponse(response, labelId);
    }
  }

  Future<
      ({
        List<Label>? labels,
        State? state,
        List<Id> notFoundIds,
      })> _fetchLabelsIfNeeded({
    required Session session,
    required AccountId accountId,
    required List<Id> labelIds,
    required State sinceState,
    required String logPrefix,
  }) async {
    if (labelIds.isEmpty) {
      return (labels: null, state: null, notFoundIds: <Id>[]);
    }

    final result = await executeBatchGetLabel(
      session: session,
      accountId: accountId,
      httpClient: _httpClient,
      labelIds: labelIds,
    );

    if (result.notFoundIds.isNotEmpty) {
      log('LabelAPI::getChanges:notFoundIds$logPrefix = ${result.notFoundIds} | SinceState = ${sinceState.value}');
    }

    return (
      labels: result.labels,
      state: result.state,
      notFoundIds: result.notFoundIds,
    );
  }

  Future<ChangesLabelResponse> getLabelChanges(
    AccountId accountId,
    State sinceState,
  ) async {
    final processingInvocation = ProcessingInvocation();
    final jmapRequestBuilder = JmapRequestBuilder(
      _httpClient,
      processingInvocation,
    );

    final changesLabelMethod = ChangesLabelMethod(
      accountId,
      sinceState,
      maxChanges: UnsignedInt(_defaultMaxChanges),
    );
    final changesLabelInvocation =
        jmapRequestBuilder.invocation(changesLabelMethod);

    final result = await (jmapRequestBuilder
          ..usings(changesLabelMethod.requiredCapabilities))
        .build()
        .execute();

    final resultChanges = result.parse<ChangesLabelResponse>(
      changesLabelInvocation.methodCallId,
      ChangesLabelResponse.deserialize,
    );

    if (resultChanges == null) {
      throw Exception('Failed to parse ChangesLabelResponse');
    }

    return resultChanges;
  }

  Future<LabelChangeResponse> getLabelChangesWithResult(
    Session session,
    AccountId accountId,
    State sinceState,
  ) async {
    final changesResult = await getLabelChanges(accountId, sinceState);

    final List<Id> createdIds = changesResult.created.toList();
    final List<Id> updatedIds = changesResult.updated.toList();
    List<Id> destroyedLabelIds = changesResult.destroyed.toList();
    final State newStateChanges = changesResult.newState;
    final bool hasMoreChanges = changesResult.hasMoreChanges;

    log('LabelAPI::getChanges:createdIds = ${createdIds.length} | updatedIds = ${updatedIds.length} | destroyedIds = ${destroyedLabelIds.length}');

    State? newStateLabel;

    final updatedResult = await _fetchLabelsIfNeeded(
      session: session,
      accountId: accountId,
      labelIds: updatedIds,
      sinceState: sinceState,
      logPrefix: 'Updated',
    );
    if (updatedResult.notFoundIds.isNotEmpty) {
      destroyedLabelIds.addAll(updatedResult.notFoundIds);
    }
    newStateLabel = updatedResult.state ?? newStateLabel;

    final createdResult = await _fetchLabelsIfNeeded(
      session: session,
      accountId: accountId,
      labelIds: createdIds,
      sinceState: sinceState,
      logPrefix: 'Created',
    );
    if (createdResult.notFoundIds.isNotEmpty) {
      destroyedLabelIds.addAll(createdResult.notFoundIds);
    }
    newStateLabel = createdResult.state ?? newStateLabel;

    log('LabelAPI::getChanges:newStateChanges = $newStateChanges | newStateLabel = $newStateLabel | hasMoreChanges = $hasMoreChanges');
    log('LabelAPI::getChanges:updatedLabelSize = ${updatedResult.labels?.length} | createdLabelSize = ${createdResult.labels?.length}');
    log('LabelAPI::getChanges:destroyedLabelIds = $destroyedLabelIds');

    return LabelChangeResponse(
      updated: updatedResult.labels,
      created: createdResult.labels,
      destroyed: destroyedLabelIds,
      newStateLabel: newStateLabel,
      newStateChanges: newStateChanges,
      hasMoreChanges: hasMoreChanges,
    );
  }
}
