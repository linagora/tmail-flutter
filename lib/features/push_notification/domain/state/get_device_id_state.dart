
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetDeviceIdLoading extends UIState {}

class GetDeviceIdSuccess extends UIState {

  final String deviceId;

  GetDeviceIdSuccess(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class GetDeviceIdFailure extends FeatureFailure {
  final dynamic exception;

  GetDeviceIdFailure(this.exception);

  @override
  List<Object> get props => [exception];
}