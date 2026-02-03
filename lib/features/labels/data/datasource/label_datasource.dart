import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/data/model/label_change_response.dart';

abstract class LabelDatasource {
  Future<List<Label>> getAllLabels(AccountId accountId);

  Future<Label> createNewLabel(AccountId accountId, Label labelData);

  Future<Label> editLabel(AccountId accountId, EditLabelRequest labelRequest);

  Future<void> deleteLabel(AccountId accountId, Label label);

  Future<LabelChangeResponse> getLabelChanges(
    Session session,
    AccountId accountId,
    State sinceState,
  );
}
