import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class SendEmailLoading extends UIState {}

class SendEmailSuccess extends UIActionState {

  SendEmailSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [];
}

class SendEmailFailure extends FeatureFailure {

  SendEmailFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}