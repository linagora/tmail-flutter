import 'package:core/core.dart';

class SaveFirebaseSuccess extends UIState {


  SaveFirebaseSuccess();

  @override
  List<Object> get props => [];
}

class SaveFirebaseFailure extends FeatureFailure {
  final dynamic exception;

  SaveFirebaseFailure(this.exception);

  @override
  List<Object> get props => [exception];
}