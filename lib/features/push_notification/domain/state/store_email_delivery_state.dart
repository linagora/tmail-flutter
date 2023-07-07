
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreEmailDeliveryStateLoading extends UIState {}

class StoreEmailDeliveryStateSuccess extends UIState {}

class StoreEmailDeliveryStateFailure extends FeatureFailure {

  StoreEmailDeliveryStateFailure(dynamic exception) : super(exception: exception);
}