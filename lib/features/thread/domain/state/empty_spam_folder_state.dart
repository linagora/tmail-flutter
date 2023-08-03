import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class EmptySpamFolderLoading extends LoadingState {}

class EmptySpamFolderSuccess extends UIActionState {

  final List<EmailId> emailIds;

  EmptySpamFolderSuccess(
    this.emailIds, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailIds, ...super.props];
}

class EmptySpamFolderFailure extends FeatureFailure {

  EmptySpamFolderFailure(dynamic exception) : super(exception: exception);
}