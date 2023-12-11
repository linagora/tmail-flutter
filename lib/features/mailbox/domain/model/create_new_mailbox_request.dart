
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class CreateNewMailboxRequest with EquatableMixin {

  final MailboxName newName;
  final MailboxId? parentId;
  final bool isSubscribed;

  CreateNewMailboxRequest({
      required this.newName,
      this.parentId,
      this.isSubscribed = true
  });

  @override
  List<Object?> get props => [newName, parentId, isSubscribed];
}