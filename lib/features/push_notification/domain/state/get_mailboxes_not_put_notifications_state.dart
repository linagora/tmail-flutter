import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class GetMailboxesNotPutNotificationsLoading extends UIState {}

class GetMailboxesNotPutNotificationsSuccess extends UIState {
  final List<PresentationMailbox> mailboxes;
  final UserName userName;
  final List<PresentationEmail> emails;
  final State currentState;

  GetMailboxesNotPutNotificationsSuccess(
    this.mailboxes,
    this.userName,
    this.emails,
    this.currentState,
  );

  @override
  List<Object> get props => [mailboxes, userName, emails, currentState];
}

class GetMailboxesNotPutNotificationsFailure extends FeatureFailure {
  final UserName userName;
  final List<PresentationEmail> emails;
  final State currentState;

  GetMailboxesNotPutNotificationsFailure(
    exception,
    this.userName,
    this.emails,
    this.currentState,
  ) : super(exception: exception);
}
