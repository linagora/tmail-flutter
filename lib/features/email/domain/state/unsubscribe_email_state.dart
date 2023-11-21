import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class UnsubscribeEmailLoading extends LoadingState {}

class UnsubscribeEmailSuccess extends UIActionState {
  final Email newEmail;

  UnsubscribeEmailSuccess(
    this.newEmail,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [newEmail, ...super.props];
}

class UnsubscribeEmailFailure extends FeatureFailure {

  UnsubscribeEmailFailure({dynamic exception}) : super(exception: exception);
}