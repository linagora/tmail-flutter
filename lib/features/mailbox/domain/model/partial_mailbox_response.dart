import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';

class PartialMailboxResponse extends MailboxResponse {

  final List<Id> mailboxNotFound;

  PartialMailboxResponse({
    required this.mailboxNotFound,
    required super.mailboxes,
    super.state,
  });

  @override
  List<Object?> get props => [mailboxNotFound, ...super.props];
}