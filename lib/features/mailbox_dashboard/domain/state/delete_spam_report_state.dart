import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteSpamReportStateLoading extends UIState {}

class DeleteSpamReportStateSuccess extends UIState {}

class DeleteSpamReportStateFailure extends FeatureFailure {

  DeleteSpamReportStateFailure(dynamic exception) : super(exception: exception);
}