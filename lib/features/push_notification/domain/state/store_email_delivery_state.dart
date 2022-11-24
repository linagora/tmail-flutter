
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreEmailDeliveryStateLoading extends UIState {}

class StoreEmailDeliveryStateSuccess extends UIState {

  StoreEmailDeliveryStateSuccess();

  @override
  List<Object> get props => [];
}

class StoreEmailDeliveryStateFailure extends FeatureFailure {
  final dynamic exception;

  StoreEmailDeliveryStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}