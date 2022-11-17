import 'package:core/core.dart';

class DeleteFirebaseSuccess extends UIState {


  DeleteFirebaseSuccess();

  @override
  List<Object> get props => [];
}

class DeleteFirebaseFailure extends FeatureFailure {
  final dynamic exception;

  DeleteFirebaseFailure(this.exception);

  @override
  List<Object> get props => [exception];
}