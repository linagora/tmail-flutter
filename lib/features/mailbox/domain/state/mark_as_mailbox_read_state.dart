import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

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

class MarkAsMailboxReadAllSuccess extends UIActionState {

  final String mailboxDisplayName;

  MarkAsMailboxReadAllSuccess(this.mailboxDisplayName,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [mailboxDisplayName];
}

class MarkAsMailboxReadHasSomeEmailFailure extends UIActionState {

  final String mailboxDisplayName;
  final int countEmailsRead;

  MarkAsMailboxReadHasSomeEmailFailure(
    this.mailboxDisplayName,
    this.countEmailsRead,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentMailboxState, currentEmailState);

  @override
  List<Object?> get props => [mailboxDisplayName, countEmailsRead];
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
  List<Object?> get props => [exception];
}