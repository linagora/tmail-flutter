
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class UnreadSpamEmailsResponse with EquatableMixin {
  final Mailbox? unreadSpamMailbox;

  UnreadSpamEmailsResponse({
    this.unreadSpamMailbox,
  });

  @override
  List<Object?> get props => [unreadSpamMailbox];
}