import 'package:core/core.dart';

class SaveFCMTokenSuccess extends UIState {


  SaveFCMTokenSuccess();

  @override
  List<Object> get props => [];
}

class SaveFCMTokenFailure extends FeatureFailure {
  final dynamic exception;

  SaveFCMTokenFailure(this.exception);

  @override
  List<Object> get props => [exception];
}