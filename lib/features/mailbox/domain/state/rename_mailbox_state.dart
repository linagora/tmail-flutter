import 'package:core/core.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class RenameMailboxSuccess extends UIActionState {

  RenameMailboxSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class RenameMailboxFailure extends FeatureFailure {
  final dynamic exception;

  RenameMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}