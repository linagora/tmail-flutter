import 'package:core/core.dart';

class DeleteFCMTokenSuccess extends UIState {


  DeleteFCMTokenSuccess();

  @override
  List<Object> get props => [];
}

class DeleteFCMTokenFailure extends FeatureFailure {
  final dynamic exception;

  DeleteFCMTokenFailure(this.exception);

  @override
  List<Object> get props => [exception];
}