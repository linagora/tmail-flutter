import 'package:core/core.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;


class LoadingSubscribeMailbox extends UIState {}

class SubscribeMailboxSuccess extends UIActionState {

  SubscribeMailboxSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class SubscribeMailboxFailure extends FeatureFailure {
  final dynamic exception;

  SubscribeMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}