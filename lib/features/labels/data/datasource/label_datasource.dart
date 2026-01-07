import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';

abstract class LabelDatasource {
  Future<List<Label>> getAllLabels(AccountId accountId);

  Future<Label> createNewLabel(AccountId accountId, Label labelData);

  Future<Label> editLabel(AccountId accountId, EditLabelRequest labelRequest);
}
