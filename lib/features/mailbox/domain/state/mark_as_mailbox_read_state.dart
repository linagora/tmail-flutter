import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAsMailboxReadLoading extends LoadingState {}

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

class MarkAsMailboxReadAllSuccess extends UIActionState {

  final MailboxId mailboxId;
  final String mailboxDisplayName;

  MarkAsMailboxReadAllSuccess(
    this.mailboxId,
    this.mailboxDisplayName,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [
    mailboxId,
    mailboxDisplayName,
    ...super.props
  ];
}

class MarkAsMailboxReadHasSomeEmailFailure extends UIActionState {

  final MailboxId mailboxId;
  final String mailboxDisplayName;
  final int countEmailsRead;

  MarkAsMailboxReadHasSomeEmailFailure(
    this.mailboxId,
    this.mailboxDisplayName,
    this.countEmailsRead,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [
    mailboxId,
    mailboxDisplayName,
    countEmailsRead,
    ...super.props
  ];
}

class MarkAsMailboxReadAllFailure extends FeatureFailure {
  final String mailboxDisplayName;

  MarkAsMailboxReadAllFailure({required this.mailboxDisplayName});

  @override
  List<Object?> get props => [mailboxDisplayName];
}

class MarkAsMailboxReadFailure extends FeatureFailure {

  final String mailboxDisplayName;

  MarkAsMailboxReadFailure({
    required this.mailboxDisplayName,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [mailboxDisplayName, ...super.props];
}