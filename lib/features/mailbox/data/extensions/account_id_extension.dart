import 'package:jmap_dart_client/jmap/account_id.dart' as JmapAccountId;
import 'package:jmap_dart_client/jmap/core/id.dart' as JmapId;
import 'package:model/model.dart';

extension AccountIdExtension on AccountId {
  JmapAccountId.AccountId toJmapAccountId() => JmapAccountId.AccountId(JmapId.Id(id.value));
}