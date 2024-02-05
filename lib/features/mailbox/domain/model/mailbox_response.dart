
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

abstract class MailboxResponse with EquatableMixin {
  final List<Mailbox> mailboxes;
  final State? state;

  MailboxResponse({
    required this.mailboxes,
    this.state
  });

  @override
  List<Object?> get props => [mailboxes, state];
}