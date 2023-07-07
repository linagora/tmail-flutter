import 'package:core/presentation/state/failure.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class MarkAsEmailReadSuccess extends UIActionState {
  final Email updatedEmail;
  final ReadActions readActions;

  MarkAsEmailReadSuccess(
    this.updatedEmail,
    this.readActions,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [updatedEmail, readActions, ...super.props];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final ReadActions readActions;

  MarkAsEmailReadFailure(this.readActions, {dynamic exception}) : super(exception: exception);

  @override
  List<Object?> get props => [readActions, ...super.props];
}