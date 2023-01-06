import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreLastTimeDismissedSpamReportLoading extends UIState {}

class StoreLastTimeDismissedSpamReportSuccess extends UIState {

  StoreLastTimeDismissedSpamReportSuccess();

  @override
  List<Object> get props => [];
}

class StoreLastTimeDismissedSpamReportFailure extends FeatureFailure {
  final dynamic exception;

  StoreLastTimeDismissedSpamReportFailure(this.exception);

  @override
  List<Object> get props => [exception];
}