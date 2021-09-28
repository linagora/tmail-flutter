
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MailboxResponse with EquatableMixin {
  final List<Mailbox>? mailboxes;
  final State? state;

  MailboxResponse({
    this.mailboxes,
    this.state
  });

  bool hasData() {
    return mailboxes != null
      && mailboxes!.isNotEmpty
      && state != null;
  }

  @override
  List<Object?> get props => [mailboxes, state];
}