import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

/// The loaded mailboxes of one other user's (delegated) account.
///
/// [mailboxState] is held per account because a session exposes a single
/// primary [BaseMailboxController.currentMailboxState], which cannot track the
/// change state of the delegated accounts. It lets each account be refreshed
/// with Mailbox/changes independently.
class OtherUserAccountMailboxes {
  final AccountId accountId;
  final MailboxName displayName;
  final List<PresentationMailbox> mailboxes;
  final jmap.State? mailboxState;

  const OtherUserAccountMailboxes({
    required this.accountId,
    required this.displayName,
    required this.mailboxes,
    this.mailboxState,
  });

  OtherUserAccountMailboxes copyWith({
    List<PresentationMailbox>? mailboxes,
    jmap.State? mailboxState,
  }) {
    return OtherUserAccountMailboxes(
      accountId: accountId,
      displayName: displayName,
      mailboxes: mailboxes ?? this.mailboxes,
      mailboxState: mailboxState ?? this.mailboxState,
    );
  }
}
