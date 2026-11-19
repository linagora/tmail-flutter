import 'package:equatable/equatable.dart';

typedef AfterDelegationLeft = Future<void> Function();

/// What one [DelegationEndedHandler] kept of the work in the ended mailbox.
class DelegationEndedHandling with EquatableMixin {
  /// Runs once the user's own mailbox is shown, never when another mailbox is shown instead.
  final AfterDelegationLeft? afterLeave;

  final int keptComposerCount;

  final List<String> droppedAttachmentNames;

  const DelegationEndedHandling({
    this.afterLeave,
    this.keptComposerCount = 0,
    this.droppedAttachmentNames = const [],
  });

  @override
  List<Object?> get props => [afterLeave, keptComposerCount, droppedAttachmentNames];
}

/// One feature's work in a delegated mailbox that the session no longer lists. See ADR-0114 §Revocation.
abstract interface class DelegationEndedHandler {
  /// Runs while the ended mailbox is still shown, before its composers close and the switch to the user's own one.
  Future<DelegationEndedHandling> beforeLeave();
}
