
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class GetMailboxesNotPutNotificationsLoading extends UIState {}

class GetMailboxesNotPutNotificationsSuccess extends UIState {

  final List<PresentationMailbox> mailboxes;

  GetMailboxesNotPutNotificationsSuccess(this.mailboxes);

  @override
  List<Object> get props => [mailboxes];
}

class GetMailboxesNotPutNotificationsFailure extends FeatureFailure {

  GetMailboxesNotPutNotificationsFailure(exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}