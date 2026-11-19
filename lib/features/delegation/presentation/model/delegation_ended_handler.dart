import 'package:equatable/equatable.dart';

typedef ShowsMine = bool Function();

/// Runs once the user's own mailbox is shown, never when another mailbox is shown instead.
/// Stops reopening work as soon as [showsMine] turns false, and returns only what it reopened.
typedef AfterDelegationLeft = Future<DelegationEndedHandling> Function(ShowsMine showsMine);

/// What one [DelegationEndedHandler] reopened of the work in the ended mailbox.
class DelegationEndedHandling with EquatableMixin {
  final int keptComposerCount;

  final List<String> droppedAttachmentNames;

  const DelegationEndedHandling({
    this.keptComposerCount = 0,
    this.droppedAttachmentNames = const [],
  });

  @override
  List<Object?> get props => [keptComposerCount, droppedAttachmentNames];
}

/// One feature's work in a delegated mailbox that the session no longer lists. See ADR-0114 §Revocation.
abstract interface class DelegationEndedHandler {
  /// Runs while the ended mailbox is still shown, before its composers close and the switch to the user's own one.
  /// Returns null when it keeps nothing.
  Future<AfterDelegationLeft?> beforeLeave();
}
