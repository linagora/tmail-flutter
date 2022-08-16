import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class DeleteMultipleEmailsPermanentlyAllSuccess extends UIActionState {

  List<EmailId> emailIds;

  DeleteMultipleEmailsPermanentlyAllSuccess(
    this.emailIds,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailIds];
}

class DeleteMultipleEmailsPermanentlyHasSomeEmailFailure extends UIActionState {

  List<EmailId> emailIds;

  DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(
    this.emailIds,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object> get props => [emailIds];
}

class DeleteMultipleEmailsPermanentlyAllFailure extends FeatureFailure {

  DeleteMultipleEmailsPermanentlyAllFailure();

  @override
  List<Object?> get props => [];
}

class DeleteMultipleEmailsPermanentlyFailure extends FeatureFailure {

  final dynamic exception;

  DeleteMultipleEmailsPermanentlyFailure(this.exception);

  @override
  List<Object?> get props => [exception];
}