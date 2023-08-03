import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class EmptyTrashFolderLoading extends LoadingState {}

class EmptyTrashFolderSuccess extends UIActionState {

  final List<EmailId> emailIds;

  EmptyTrashFolderSuccess(
      this.emailIds, {
        jmap.State? currentEmailState,
        jmap.State? currentMailboxState,
      }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailIds, ...super.props];
}

class EmptyTrashFolderFailure extends FeatureFailure {

  EmptyTrashFolderFailure(dynamic exception) : super(exception: exception);
}