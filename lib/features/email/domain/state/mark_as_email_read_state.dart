import 'package:core/core.dart';
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
  List<Object?> get props => [updatedEmail, readActions];
}

class MarkAsEmailReadFailure extends FeatureFailure {
  final dynamic exception;
  final ReadActions readActions;

  MarkAsEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}