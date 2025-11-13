import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/quotas/data/datasource/quotas_data_source.dart';
import 'package:tmail_ui_user/features/quotas/data/network/quotas_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class QuotasDataSourceImpl  extends QuotasDataSource {
  final QuotasAPI _quotasAPI;
  final ExceptionThrower _exceptionThrower;

  QuotasDataSourceImpl(this._quotasAPI, this._exceptionThrower);

  @override
  Future<List<Quota>> getQuotas(AccountId accountId) {
    return Future.sync(() async {
      return await _quotasAPI.getQuotas(accountId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}