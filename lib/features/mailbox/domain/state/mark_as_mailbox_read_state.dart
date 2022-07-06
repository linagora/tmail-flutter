import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MarkAsMailboxReadLoading extends UIState {

  MarkAsMailboxReadLoading();

  @override
  List<Object?> get props => [];
}

class UpdatingMarkAsMailboxReadState extends UIState {

  final MailboxId mailboxId;
  final int totalUnread;
  final int countRead;

  UpdatingMarkAsMailboxReadState({
    required this.mailboxId,
    required this.totalUnread,
    required this.countRead});

  @override
  List<Object?> get props => [mailboxId, countRead, totalUnread];
}

class MarkAsMailboxReadAllSuccess extends UIState {

  final MailboxName mailboxName;

  MarkAsMailboxReadAllSuccess(this.mailboxName);

  @override
  List<Object?> get props => [mailboxName];
}

class MarkAsMailboxReadHasSomeEmailFailure extends UIState {

  final MailboxName mailboxName;
  final int countEmailsRead;

  MarkAsMailboxReadHasSomeEmailFailure(this.mailboxName, this.countEmailsRead);

  @override
  List<Object?> get props => [mailboxName, countEmailsRead];
}

class MarkAsMailboxReadAllFailure extends FeatureFailure {

  MarkAsMailboxReadAllFailure();

  @override
  List<Object?> get props => [];
}

class MarkAsMailboxReadFailure extends FeatureFailure {
  final dynamic exception;

  MarkAsMailboxReadFailure(this.exception);

  @override
  List<Object> get props => [exception];
}