
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class CreateNewMailboxRequest with EquatableMixin {

  final MailboxName newName;
  final Id creationId;
  final MailboxId? parentId;

  CreateNewMailboxRequest(this.creationId, this.newName, {this.parentId});

  @override
  List<Object?> get props => [creationId, newName, parentId];
}