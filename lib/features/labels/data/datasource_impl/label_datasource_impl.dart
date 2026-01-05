import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/data/datasource/label_datasource.dart';
import 'package:tmail_ui_user/features/labels/data/network/label_api.dart';
import 'package:tmail_ui_user/features/labels/domain/model/edit_label_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LabelDatasourceImpl extends LabelDatasource {
  final LabelApi _labelApi;
  final ExceptionThrower _exceptionThrower;

  LabelDatasourceImpl(this._labelApi, this._exceptionThrower);

  @override
  Future<List<Label>> getAllLabels(AccountId accountId) {
    return Future.sync(() async {
      return await _labelApi.getAllLabels(accountId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Label> createNewLabel(AccountId accountId, Label labelData) {
    return Future.sync(() async {
      return await _labelApi.createNewLabel(accountId, labelData);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Label> editLabel(AccountId accountId, EditLabelRequest labelRequest) {
    return Future.sync(() async {
      return await _labelApi.editLabel(accountId, labelRequest);
    }).catchError(_exceptionThrower.throwException);
  }
}
