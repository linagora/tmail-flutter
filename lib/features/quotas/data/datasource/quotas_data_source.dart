import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/quotas/domain/model/quotas_response.dart';

abstract class QuotasDataSource {
  Future<QuotasResponse> getQuotas(AccountId accountId);
}
