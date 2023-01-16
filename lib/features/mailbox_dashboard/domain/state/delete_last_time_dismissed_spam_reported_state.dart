import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteLastTimeDismissedSpamReportedLoading extends UIState {}

class DeleteLastTimeDismissedSpamReportedSuccess extends UIState {

  DeleteLastTimeDismissedSpamReportedSuccess();

  @override
  List<Object> get props => [];
}

class DeleteLastTimeDismissedSpamReportedFailure extends FeatureFailure {
  final dynamic exception;

  DeleteLastTimeDismissedSpamReportedFailure(this.exception);

  @override
  List<Object> get props => [exception];
}