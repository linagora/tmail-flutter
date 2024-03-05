import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class UpdatingEmailDrafts extends LoadingState {}

class UpdateEmailDraftsSuccess extends UIActionState {

  final EmailId emailId;

  UpdateEmailDraftsSuccess(
    this.emailId,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailId, ...super.props];
}

class UpdateEmailDraftsFailure extends FeatureFailure {

  UpdateEmailDraftsFailure(dynamic exception) : super(exception: exception);
}