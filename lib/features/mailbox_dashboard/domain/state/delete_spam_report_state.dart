import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteSpamReportStateLoading extends UIState {}

class DeleteSpamReportStateSuccess extends UIState {

  DeleteSpamReportStateSuccess();

  @override
  List<Object> get props => [];
}

class DeleteSpamReportStateFailure extends FeatureFailure {
  final dynamic exception;

  DeleteSpamReportStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}