import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetUnreadSpamMailboxLoading extends UIState {}

class GetUnreadSpamMailboxSuccess extends UIState {
  final Mailbox unreadSpamMailbox;

  GetUnreadSpamMailboxSuccess(this.unreadSpamMailbox);

  @override
  List<Object> get props => [unreadSpamMailbox];
}

class InvalidSpamReportCondition extends FeatureFailure {
  @override
  List<Object?> get props => [];
}

class GetUnreadSpamMailboxFailure extends FeatureFailure {
  final dynamic exception;

  GetUnreadSpamMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}