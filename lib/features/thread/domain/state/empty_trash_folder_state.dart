import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class EmptyTrashFolderSuccess extends UIActionState {

  EmptyTrashFolderSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);
}

class EmptyTrashFolderFailure extends FeatureFailure {

  EmptyTrashFolderFailure(dynamic exception) : super(exception: exception);
}