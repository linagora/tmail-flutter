import 'package:core/core.dart';
import 'package:model/fcm/fcm_token_dto.dart';

class GetFCMTokenSuccess extends UIState {

  final FCMTokenDto firebaseDto;

  GetFCMTokenSuccess(this.firebaseDto);

  @override
  List<Object> get props => [firebaseDto];
}

class GetFCMTokenFailure extends FeatureFailure {
  final dynamic exception;

  GetFCMTokenFailure(this.exception);

  @override
  List<Object> get props => [exception];
}