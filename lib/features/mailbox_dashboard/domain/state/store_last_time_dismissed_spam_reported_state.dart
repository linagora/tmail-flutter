import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreLastTimeDismissedSpamReportLoading extends UIState {}

class StoreLastTimeDismissedSpamReportSuccess extends UIState {}

class StoreLastTimeDismissedSpamReportFailure extends FeatureFailure {

  StoreLastTimeDismissedSpamReportFailure(dynamic exception) : super(exception: exception);
}