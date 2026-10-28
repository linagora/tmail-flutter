import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';

class SwitchAttemptStamp {
  final ActiveAccountSource _source;
  final int attemptId;

  SwitchAttemptStamp(this._source) : attemptId = _source.currentSwitchAttemptId;

  /// The one check that drops view results of an ended attempt (ADR-0114 §Switching).
  bool get isCurrent => _source.currentSwitchAttemptId == attemptId;
}
