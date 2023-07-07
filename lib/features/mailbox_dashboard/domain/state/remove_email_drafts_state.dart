import 'package:core/presentation/state/failure.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class RemoveEmailDraftsSuccess extends UIActionState {

  RemoveEmailDraftsSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);
}

class RemoveEmailDraftsFailure extends FeatureFailure {

  RemoveEmailDraftsFailure(dynamic exception) : super(exception: exception);
}