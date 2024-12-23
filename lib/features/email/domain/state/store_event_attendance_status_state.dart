import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

class StoreEventAttendanceStatusLoading extends LoadingState {}

class StoreEventAttendanceStatusSuccess extends UIState {

  final EventActionType eventActionType;

  StoreEventAttendanceStatusSuccess(this.eventActionType);

  @override
  List<Object?> get props => [eventActionType];
}

class StoreEventAttendanceStatusFailure extends FeatureFailure {

  StoreEventAttendanceStatusFailure({dynamic exception}) : super(exception: exception);
}