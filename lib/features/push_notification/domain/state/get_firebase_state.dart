import 'package:core/core.dart';
import 'package:model/firebase/firebase_dto.dart';

class GetFirebaseSuccess extends UIState {

  final FirebaseDto firebaseDto;

  GetFirebaseSuccess(this.firebaseDto);

  @override
  List<Object> get props => [firebaseDto];
}

class GetFirebaseFailure extends FeatureFailure {
  final dynamic exception;

  GetFirebaseFailure(this.exception);

  @override
  List<Object> get props => [exception];
}