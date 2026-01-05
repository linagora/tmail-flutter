import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/data/datasource/label_datasource.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';

class LabelRepositoryImpl extends LabelRepository {
  final LabelDatasource _labelDatasource;

  LabelRepositoryImpl(this._labelDatasource);

  @override
  Future<List<Label>> getAllLabels(AccountId accountId) {
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
}
