import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/data/datasource/label_datasource.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';

class LabelRepositoryImpl extends LabelRepository {
  final LabelDatasource _labelDatasource;

  LabelRepositoryImpl(this._labelDatasource);

  @override
  Future<List<Label>> getAllLabels(AccountId accountId) {
    return _labelDatasource.getAllLabels(accountId);
  }
}
