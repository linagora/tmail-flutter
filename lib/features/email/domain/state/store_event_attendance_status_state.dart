import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

class StoreEventAttendanceStatusLoading extends LoadingState {}

class StoreEventAttendanceStatusSuccess extends UIActionState {

  final EventActionType eventActionType;
  final Email updatedEmail;

  StoreEventAttendanceStatusSuccess(
    this.eventActionType,
    this.updatedEmail,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    eventActionType,
    updatedEmail,
    ...super.props];
}

class StoreEventAttendanceStatusFailure extends FeatureFailure {

  StoreEventAttendanceStatusFailure({dynamic exception}) : super(exception: exception);
}