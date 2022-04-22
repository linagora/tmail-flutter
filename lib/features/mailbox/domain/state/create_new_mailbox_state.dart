import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class CreateNewMailboxSuccess extends UIState {

  final Mailbox newMailbox;

  CreateNewMailboxSuccess(this.newMailbox);

  @override
  List<Object?> get props => [newMailbox];
}

class CreateNewMailboxFailure extends FeatureFailure {
  final dynamic exception;

  CreateNewMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}