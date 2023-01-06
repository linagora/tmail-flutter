import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetLastTimeDismissedSpamReportedLoading extends UIState {}

class GetLastTimeDismissedSpamReportedSuccess extends UIState {
  final DateTime lastTimeDismissedSpamReported;

  GetLastTimeDismissedSpamReportedSuccess(this.lastTimeDismissedSpamReported);

  @override
  List<Object> get props => [];
}

class GetLastTimeDismissedSpamReportedFailure extends FeatureFailure {
  final dynamic exception;

  GetLastTimeDismissedSpamReportedFailure(this.exception);

  @override
  List<Object> get props => [exception];
}