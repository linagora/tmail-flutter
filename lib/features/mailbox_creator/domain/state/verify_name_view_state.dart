
import 'package:core/core.dart';

class VerifyNameViewState extends UIState {
  VerifyNameViewState();

  @override
  List<Object> get props => [];
}

class VerifyNameFailure extends FeatureFailure {
  final exception;

  VerifyNameFailure(this.exception);
  @override
  List<Object> get props => [exception];
}