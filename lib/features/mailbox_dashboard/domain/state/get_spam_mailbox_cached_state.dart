import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetSpamMailboxCachedLoading extends UIState {}

class GetSpamMailboxCachedSuccess extends UIState {

  final Mailbox spamMailbox;

  GetSpamMailboxCachedSuccess(this.spamMailbox);

  @override
  List<Object> get props => [spamMailbox];
}

class GetSpamMailboxCachedFailure extends FeatureFailure {

  GetSpamMailboxCachedFailure(exception) : super(exception: exception);
}

class InvalidSpamReportCondition extends FeatureFailure {}