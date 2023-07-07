import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteLastTimeDismissedSpamReportedLoading extends UIState {}

class DeleteLastTimeDismissedSpamReportedSuccess extends UIState {}

class DeleteLastTimeDismissedSpamReportedFailure extends FeatureFailure {

  DeleteLastTimeDismissedSpamReportedFailure(dynamic exception) : super(exception: exception);
}