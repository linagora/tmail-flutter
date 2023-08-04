import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/quotas/data/datasource/quotas_data_source.dart';
import 'package:tmail_ui_user/features/quotas/domain/repository/quotas_repository.dart';

class QuotasRepositoryImpl extends QuotasRepository {
  final QuotasDataSource _dataSource;

  QuotasRepositoryImpl(this._dataSource);

  @override
  Future<List<Quota>> getQuotas(AccountId accountId) {
    return _dataSource.getQuotas(accountId);
  }
}
