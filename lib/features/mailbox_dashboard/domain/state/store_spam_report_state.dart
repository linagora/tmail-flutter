import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSpamReportLoading extends UIState {}

class StoreSpamReportSuccess extends UIState {

  StoreSpamReportSuccess();

  @override
  List<Object> get props => [];
}

class StoreSpamReportFailure extends FeatureFailure {
  final dynamic exception;

  StoreSpamReportFailure(this.exception);

  @override
  List<Object> get props => [exception];
}