
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

extension ListQuotasExtensions on List<Quota> {

  Quota? get octetsQuota {
    try {
      return firstWhere((quota) => quota.resourceType == ResourceType.octets);
    } catch(e) {
      logError('ListQuotasExtensions::octetsQuota: Not found octets quota');
      return null;
    }
  }
}