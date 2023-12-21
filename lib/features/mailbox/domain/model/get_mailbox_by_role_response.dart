import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetMailboxByRoleResponse with EquatableMixin {
  final Mailbox? mailbox;

  GetMailboxByRoleResponse({
    this.mailbox,
  });

  @override
  List<Object?> get props => [
    mailbox,
  ];
}