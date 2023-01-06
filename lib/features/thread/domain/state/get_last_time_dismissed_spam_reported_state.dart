import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetLastTimeDismissedSpamReportLoading extends UIState {}

class GetLastTimeDismissedSpamReportSuccess extends UIState {
  final DateTime lastTimeDismissedSpamReport;

  GetLastTimeDismissedSpamReportSuccess(this.lastTimeDismissedSpamReport);

  @override
  List<Object> get props => [];
}

class GetLastTimeDismissedSpamReportFailure extends FeatureFailure {
  final dynamic exception;

  GetLastTimeDismissedSpamReportFailure(this.exception);

  @override
  List<Object> get props => [exception];
}