import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MarkAsMailboxReadLoading extends UIState {

  MarkAsMailboxReadLoading();

  @override
  List<Object?> get props => [];
}

class MarkAsMailboxReadAllSuccess extends UIState {

  final MailboxName mailboxName;

  MarkAsMailboxReadAllSuccess(this.mailboxName);

  @override
  List<Object?> get props => [mailboxName];
}

class MarkAsMailboxReadHasSomeEmailFailure extends FeatureFailure {

  MarkAsMailboxReadHasSomeEmailFailure();

  @override
  List<Object?> get props => [];
}

class MarkAsMailboxReadFailure extends FeatureFailure {
  final dynamic exception;

  MarkAsMailboxReadFailure(this.exception);

  @override
  List<Object> get props => [exception];
}