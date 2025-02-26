import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MarkAllAsUnreadSelectionAllEmailsLoading extends LoadingState {}

class MarkAllAsUnreadSelectionAllEmailsUpdating extends UIState {

  final MailboxId mailboxId;
  final int totalRead;
  final int countUnread;

  MarkAllAsUnreadSelectionAllEmailsUpdating({
    required this.mailboxId,
    required this.totalRead,
    required this.countUnread
  });

  @override
  List<Object?> get props => [mailboxId, totalRead, countUnread];
}

class MarkAllAsUnreadSelectionAllEmailsAllSuccess extends UIState {

  final String mailboxDisplayName;

  MarkAllAsUnreadSelectionAllEmailsAllSuccess(this.mailboxDisplayName);

  @override
  List<Object?> get props => [mailboxDisplayName];
}

class MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure extends UIState {

  final String mailboxDisplayName;
  final int countEmailsUnread;

  MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(
    this.mailboxDisplayName,
    this.countEmailsUnread,
  );

  @override
  List<Object?> get props => [
    mailboxDisplayName,
    countEmailsUnread,
  ];
}

class MarkAllAsUnreadSelectionAllEmailsFailure extends FeatureFailure {

  final String mailboxDisplayName;

  MarkAllAsUnreadSelectionAllEmailsFailure({
    required this.mailboxDisplayName,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [mailboxDisplayName, ...super.props];
}