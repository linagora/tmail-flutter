import 'package:core/core.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class StartDeleteEmailPermanently extends UIState {

  StartDeleteEmailPermanently();

  @override
  List<Object?> get props => [];
}

class DeleteEmailPermanentlySuccess extends UIActionState {

  DeleteEmailPermanentlySuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class DeleteEmailPermanentlyFailure extends FeatureFailure {

  final dynamic exception;

  DeleteEmailPermanentlyFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}