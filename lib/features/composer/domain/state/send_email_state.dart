import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class SendingEmailState extends UIState {
  SendingEmailState();

  @override
  List<Object?> get props => [];
}

class SendEmailSuccess extends UIActionState {

  SendEmailSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class SendEmailFailure extends FeatureFailure {
  final dynamic exception;

  SendEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}