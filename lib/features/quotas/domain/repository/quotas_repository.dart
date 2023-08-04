import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

abstract class QuotasRepository {
  Future<List<Quota>> getQuotas(AccountId accountId);
}
