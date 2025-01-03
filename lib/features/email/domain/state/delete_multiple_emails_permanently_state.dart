import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class LoadingDeleteMultipleEmailsPermanentlyAll extends UIState {}

class DeleteMultipleEmailsPermanentlyAllSuccess extends UIState {

  final List<EmailId> emailIds;
  final MailboxId? mailboxId;

  DeleteMultipleEmailsPermanentlyAllSuccess(this.emailIds, this.mailboxId);

  @override
  List<Object?> get props => [emailIds, mailboxId];
}

class DeleteMultipleEmailsPermanentlyHasSomeEmailFailure extends UIState {

  final List<EmailId> emailIds;
  final MailboxId? mailboxId;

  DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(this.emailIds, this.mailboxId);

  @override
  List<Object?> get props => [emailIds, mailboxId];
}

class DeleteMultipleEmailsPermanentlyAllFailure extends FeatureFailure {}

class DeleteMultipleEmailsPermanentlyFailure extends FeatureFailure {

  DeleteMultipleEmailsPermanentlyFailure(dynamic exception) : super(exception: exception);
}