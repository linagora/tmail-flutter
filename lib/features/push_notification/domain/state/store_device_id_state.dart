
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreDeviceIdLoading extends UIState {}

class StoreDeviceIdSuccess extends UIState {

  StoreDeviceIdSuccess();

  @override
  List<Object> get props => [];
}

class StoreDeviceIdFailure extends FeatureFailure {
  final dynamic exception;

  StoreDeviceIdFailure(this.exception);

  @override
  List<Object> get props => [exception];
}