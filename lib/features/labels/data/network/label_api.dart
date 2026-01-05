import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:uuid/uuid.dart';

class LabelApi with HandleSetErrorMixin {
  final HttpClient _httpClient;
  final Uuid _uuid;

  LabelApi(this._httpClient, this._uuid);

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

    final labelCreated = response?.created?[generateCreateId];

    if (labelCreated != null) {
      final newLabelCreated = labelCreated.copyWith(
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

    final labelUpdated = response?.updated?[labelId];

    if (labelUpdated != null) {
      final newLabelUpdated = newLabel.copyWith(
        id: labelId,
        keyword: labelRequest.labelKeyword,
      );
      return newLabelUpdated;
    } else {
      throw parseErrorForSetResponse(response, labelId);
    }
  }
}
