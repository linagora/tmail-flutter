import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class LoadingCreateNewMailbox extends UIState {}

class CreateNewMailboxSuccess extends UIActionState {

  final Mailbox newMailbox;

  CreateNewMailboxSuccess(this.newMailbox, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [newMailbox, ...super.props];
}

class CreateNewMailboxFailure extends FeatureFailure {

  CreateNewMailboxFailure(dynamic exception) : super(exception: exception);
}