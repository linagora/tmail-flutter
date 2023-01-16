import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSpamReportStateLoading extends UIState {}

class StoreSpamReportStateSuccess extends UIState {

  StoreSpamReportStateSuccess();

  @override
  List<Object> get props => [];
}

class StoreSpamReportStateFailure extends FeatureFailure {
  final dynamic exception;

  StoreSpamReportStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}