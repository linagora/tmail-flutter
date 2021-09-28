
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';

extension StateCacheExtension on StateCache {
  State toState() {
    return State(state);
  }
}