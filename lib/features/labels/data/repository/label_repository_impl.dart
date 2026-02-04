import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/data/datasource/label_datasource.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/domain/model/label_changes_result.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';

class LabelRepositoryImpl extends LabelRepository {
  final LabelDatasource _labelDatasource;

  LabelRepositoryImpl(this._labelDatasource);

  @override
  Future<({List<Label> labels, State? newState})> getAllLabels(AccountId accountId) {
    return _labelDatasource.getAllLabels(accountId);
  }

  @override
  Future<Label> createNewLabel(AccountId accountId, Label labelData) {
    return _labelDatasource.createNewLabel(accountId, labelData);
  }

  @override
  Future<Label> editLabel(AccountId accountId, EditLabelRequest labelRequest) {
    return _labelDatasource.editLabel(accountId, labelRequest);
  }

  @override
  Future<void> deleteLabel(AccountId accountId, Label label) {
    return _labelDatasource.deleteLabel(accountId, label);
  }

  @override
  Future<LabelChangesResult> getLabelChanges(
    Session session,
    AccountId accountId,
    State sinceState,
  ) async {
    bool hasMoreChanges = true;
    State? newSinceState = sinceState;
    List<Label> createdLabels = [];
    List<Label> updatedLabels = [];
    List<Id> destroyedLabelIds = [];
    State? newState;

    while (hasMoreChanges && newSinceState != null) {
      final changesResponse = await _labelDatasource.getLabelChanges(
        session,
        accountId,
        newSinceState,
      );

      hasMoreChanges = changesResponse.hasMoreChanges;
      newSinceState = changesResponse.newStateChanges;

      if (changesResponse.created?.isNotEmpty == true) {
        createdLabels.addAll(changesResponse.created!);
      }
      if (changesResponse.updated?.isNotEmpty == true) {
        updatedLabels.addAll(changesResponse.updated!);
      }
      if (changesResponse.destroyed?.isNotEmpty == true) {
        destroyedLabelIds.addAll(changesResponse.destroyed!);
      }
      if (changesResponse.newStateChanges != null) {
        newState = changesResponse.newStateChanges!;
      }
    }

    return LabelChangesResult(
      createdLabels: createdLabels,
      updatedLabels: updatedLabels,
      destroyedLabelIds: destroyedLabelIds,
      newState: newState,
    );
  }
}
