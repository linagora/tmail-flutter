import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';

extension StateChangeMergeExtension on StateChange {
  /// Later type keys for the same account win. Used by the WebSocket and FCM debouncers.
  StateChange mergeWith(StateChange later) {
    final merged = <AccountId, TypeState>{...changed};
    later.changed.forEach((accountId, typeState) {
      final previous = merged[accountId]?.typeState ?? const <String, dynamic>{};
      merged[accountId] = TypeState({...previous, ...typeState.typeState});
    });
    return StateChange(later.type, merged);
  }
}

extension StateChangeListMergeExtension on Iterable<StateChange> {
  StateChange? mergeAll() {
    StateChange? merged;
    for (final change in this) {
      merged = merged == null ? change : merged.mergeWith(change);
    }
    return merged;
  }
}
