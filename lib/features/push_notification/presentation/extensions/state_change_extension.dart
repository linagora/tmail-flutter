
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';

extension StateChangeExtension on StateChange? {

  Map<String, dynamic> getMapTypeState(AccountId accountId) {
    return this?.changed[accountId]?.typeState ?? {};
  }
}