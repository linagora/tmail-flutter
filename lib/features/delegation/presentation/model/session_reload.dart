import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// A server session re-read and applied to the shown account. See ADR-0114 §Revocation.
class SessionReload with EquatableMixin {
  final Session session;

  /// The owner of the shown mailbox, when this session no longer lists it.
  final String? revokedOwnerEmailAddress;

  /// Composers of the revoked mailbox closed without saving.
  final int lostComposerCount;

  /// Composers of the revoked mailbox reopened in the user's own one.
  final int keptComposerCount;

  /// Files of the kept composers, which stay in the revoked mailbox.
  final List<String> droppedAttachmentNames;

  /// The switch away from the revoked mailbox failed or timed out, so its mails may still be shown.
  final bool couldNotReturnToMine;

  const SessionReload(
    this.session, {
    this.revokedOwnerEmailAddress,
    this.lostComposerCount = 0,
    this.keptComposerCount = 0,
    this.droppedAttachmentNames = const [],
    this.couldNotReturnToMine = false,
  });

  @override
  List<Object?> get props => [
        session,
        revokedOwnerEmailAddress,
        lostComposerCount,
        keptComposerCount,
        droppedAttachmentNames,
        couldNotReturnToMine,
      ];
}
