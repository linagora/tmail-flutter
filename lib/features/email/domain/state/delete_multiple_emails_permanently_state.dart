import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class LoadingDeleteMultipleEmailsPermanentlyAll extends UIState {}

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
  List<Object?> get props => [emailIds, ...super.props];
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
  List<Object?> get props => [emailIds, ...super.props];
}

class DeleteMultipleEmailsPermanentlyAllFailure extends FeatureFailure {}

class DeleteMultipleEmailsPermanentlyFailure extends FeatureFailure {

  DeleteMultipleEmailsPermanentlyFailure(dynamic exception) : super(exception: exception);
}