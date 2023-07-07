import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class StartDeleteEmailPermanently extends UIState {}

class DeleteEmailPermanentlySuccess extends UIActionState {

  DeleteEmailPermanentlySuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);
}

class DeleteEmailPermanentlyFailure extends FeatureFailure {

  DeleteEmailPermanentlyFailure(dynamic exception) : super(exception: exception);
}