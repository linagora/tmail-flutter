import 'package:core/core.dart';
import 'package:model/email/read_actions.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAsMultipleEmailReadAllSuccess extends UIActionState {
  final int countMarkAsReadSuccess;
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllSuccess(
      this.countMarkAsReadSuccess,
      this.readActions,
      {
        jmap.State? currentEmailState,
        jmap.State? currentMailboxState,
      }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [countMarkAsReadSuccess, readActions];
}

class MarkAsMultipleEmailReadAllFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllFailure(this.readActions);

  @override
  List<Object> get props => [readActions];
}

class MarkAsMultipleEmailReadHasSomeEmailFailure extends UIActionState {
  final int countMarkAsReadSuccess;
  final ReadActions readActions;

  MarkAsMultipleEmailReadHasSomeEmailFailure(
    this.countMarkAsReadSuccess,
    this.readActions,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object> get props => [countMarkAsReadSuccess, readActions];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final dynamic exception;
  final ReadActions readActions;

  MarkAsMultipleEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}