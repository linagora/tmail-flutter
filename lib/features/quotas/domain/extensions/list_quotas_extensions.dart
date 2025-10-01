import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

extension ListQuotasExtensions on List<Quota> {
  Quota? get octetsQuota =>
      firstWhereOrNull((quota) => quota.resourceType == ResourceType.octets);
}