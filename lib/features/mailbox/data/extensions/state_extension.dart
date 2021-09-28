
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';

extension StateExtension on State {
  StateCache toStateCache(StateType stateType) {
    return StateCache(stateType, value);
  }
}