import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class DeleteMultipleMailboxSuccess extends UIActionState {

  final MailboxId mailboxIdDeleted;

  DeleteMultipleMailboxSuccess(this.mailboxIdDeleted, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [mailboxIdDeleted];
}

class DeleteMultipleMailboxFailure extends FeatureFailure {
  final dynamic exception;

  DeleteMultipleMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}