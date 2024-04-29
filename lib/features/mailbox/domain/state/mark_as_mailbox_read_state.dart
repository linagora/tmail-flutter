import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
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

  final String mailboxDisplayName;
  final MailboxId mailboxId;

  MarkAsMailboxReadAllSuccess(this.mailboxDisplayName,
    this.mailboxId,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [
    mailboxDisplayName,
    mailboxId,
    ...super.props
  ];
}

class MarkAsMailboxReadHasSomeEmailFailure extends UIState {

  final String mailboxDisplayName;
  final int countEmailsRead;
  final MailboxId mailboxId;
  final List<EmailId> successEmailIds;

  MarkAsMailboxReadHasSomeEmailFailure(
    this.mailboxDisplayName,
    this.countEmailsRead,
    this.mailboxId,
    this.successEmailIds,
  );

  @override
  List<Object?> get props => [
    mailboxDisplayName,
    countEmailsRead,
    mailboxId,
    successEmailIds,
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
}