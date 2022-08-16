import 'package:core/core.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class EmptyTrashFolderSuccess extends UIActionState {

  EmptyTrashFolderSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class EmptyTrashFolderFailure extends FeatureFailure {
  final dynamic exception;

  EmptyTrashFolderFailure(this.exception);

  @override
  List<Object> get props => [exception];
}