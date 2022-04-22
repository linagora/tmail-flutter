import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class DeleteMultipleMailboxSuccess extends UIState {

  final MailboxId mailboxIdDeleted;

  DeleteMultipleMailboxSuccess(this.mailboxIdDeleted);

  @override
  List<Object?> get props => [mailboxIdDeleted];
}

class DeleteMultipleMailboxFailure extends FeatureFailure {
  final dynamic exception;

  DeleteMultipleMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}