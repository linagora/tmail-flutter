import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class SaveEmailAsDraftsLoading extends LoadingState {}

class SaveEmailAsDraftsSuccess extends UIActionState {

  final EmailId emailId;

  SaveEmailAsDraftsSuccess(
    this.emailId,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailId, ...super.props];
}

class SaveEmailAsDraftsFailure extends FeatureFailure {

  SaveEmailAsDraftsFailure(dynamic exception) : super(exception: exception);
}

class CancelSavingEmailToDrafts extends LoadingState {}