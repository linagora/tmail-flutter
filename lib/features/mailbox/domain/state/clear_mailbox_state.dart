import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class ClearingMailbox extends LoadingState {}

class ClearMailboxSuccess extends UIState {
  final UnsignedInt totalDeletedMessages;
  final MailboxId mailboxId;
  final Role mailboxRole;

  ClearMailboxSuccess(this.mailboxId, this.mailboxRole, this.totalDeletedMessages);

  @override
  List<Object> get props => [mailboxId, mailboxRole, totalDeletedMessages];
}

class ClearMailboxFailure extends FeatureFailure {
  final Role mailboxRole;

  ClearMailboxFailure(this.mailboxRole, {dynamic exception}) : super(exception: exception);
}