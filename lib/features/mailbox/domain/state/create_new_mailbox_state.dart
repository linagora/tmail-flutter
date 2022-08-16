import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class CreateNewMailboxSuccess extends UIActionState {

  final Mailbox newMailbox;

  CreateNewMailboxSuccess(this.newMailbox, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [newMailbox];
}

class CreateNewMailboxFailure extends FeatureFailure {
  final dynamic exception;

  CreateNewMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}