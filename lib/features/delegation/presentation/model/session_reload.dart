import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// A server session re-read and applied to the shown account. See ADR-0114 §Revocation.
class SessionReload with EquatableMixin {
  final Session session;

  /// The owner of the shown mailbox, when this session no longer lists it.
  final String? revokedOwnerEmailAddress;

  /// Composers of the revoked mailbox closed without saving.
  final int closedComposerCount;

  /// The switch away from the revoked mailbox failed or timed out, so its mails may still be shown.
  final bool couldNotReturnToMine;

  const SessionReload(
    this.session, {
    this.revokedOwnerEmailAddress,
    this.closedComposerCount = 0,
    this.couldNotReturnToMine = false,
  });

  @override
  List<Object?> get props => [session, revokedOwnerEmailAddress, closedComposerCount, couldNotReturnToMine];
}
