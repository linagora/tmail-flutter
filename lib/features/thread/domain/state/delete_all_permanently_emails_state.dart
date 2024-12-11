import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class DeleteAllPermanentlyEmailsLoading extends LoadingState {}

class DeleteAllPermanentlyEmailsUpdating extends UIState {

  final int total;
  final int countDeleted;

  DeleteAllPermanentlyEmailsUpdating({
    required this.total,
    required this.countDeleted
  });

  @override
  List<Object?> get props => [total, countDeleted];
}

class DeleteAllPermanentlyEmailsSuccess extends UIActionState {

  final List<EmailId> emailIds;

  DeleteAllPermanentlyEmailsSuccess(
    this.emailIds, {
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [emailIds, ...super.props];
}

class DeleteAllPermanentlyEmailsFailure extends FeatureFailure {

  DeleteAllPermanentlyEmailsFailure(dynamic exception) : super(exception: exception);
}