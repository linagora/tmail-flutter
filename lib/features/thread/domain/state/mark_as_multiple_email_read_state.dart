import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/read_actions.dart';

class LoadingMarkAsMultipleEmailReadAll extends UIState {}

class MarkAsMultipleEmailReadAllSuccess extends UIState {
  final List<EmailId> emailIds;
  final ReadActions readActions;
  final MailboxId? mailboxId;

  MarkAsMultipleEmailReadAllSuccess(
    this.emailIds,
    this.readActions,
    this.mailboxId,
  );

  @override
  List<Object?> get props => [emailIds, readActions, mailboxId];
}

class MarkAsMultipleEmailReadAllFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllFailure(this.readActions);

  @override
  List<Object> get props => [readActions];
}

class MarkAsMultipleEmailReadHasSomeEmailFailure extends UIState {
  final List<EmailId> successEmailIds;
  final ReadActions readActions;
  final MailboxId? mailboxId;

  MarkAsMultipleEmailReadHasSomeEmailFailure(
    this.successEmailIds,
    this.readActions,
    this.mailboxId,
  );

  @override
  List<Object?> get props => [successEmailIds, readActions, mailboxId];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsMultipleEmailReadFailure(this.readActions, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [readActions, exception];
}