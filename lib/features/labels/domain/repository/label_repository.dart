import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';

abstract class LabelRepository {
  Future<List<Label>> getAllLabels(AccountId accountId);

  Future<Label> createNewLabel(AccountId accountId, Label labelData);

  Future<void> deleteLabel(AccountId accountId, Label label);
}
