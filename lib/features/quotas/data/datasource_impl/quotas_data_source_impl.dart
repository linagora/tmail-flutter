import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/quotas/data/datasource/quotas_data_source.dart';
import 'package:tmail_ui_user/features/quotas/data/network/quotas_api.dart';
import 'package:tmail_ui_user/features/quotas/domain/model/quotas_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class QuotasDataSourceImpl  extends QuotasDataSource{
  final QuotasAPI _quotasAPI;
  final ExceptionThrower _exceptionThrower;

  QuotasDataSourceImpl(this._quotasAPI, this._exceptionThrower);

  @override
  Future<QuotasResponse> getQuotas(AccountId accountId) {
    return Future.sync(() async {
      return await _quotasAPI.getQuotas(accountId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}