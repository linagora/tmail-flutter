import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class CreateDefaultMailboxLoading extends LoadingState {}

class CreateDefaultMailboxAllSuccess extends UIActionState {
  CreateDefaultMailboxAllSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [...super.props];
}

class CreateDefaultMailboxFailure extends FeatureFailure {
  final jmap.State? currentMailboxState;

  CreateDefaultMailboxFailure(this.currentMailboxState, dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [currentMailboxState, exception];
}