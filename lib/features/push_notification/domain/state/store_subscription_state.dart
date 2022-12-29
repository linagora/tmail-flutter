
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSubscriptionLoading extends UIState {}

class StoreSubscriptionSuccess extends UIState {

  StoreSubscriptionSuccess();

  @override
  List<Object> get props => [];
}

class StoreSubscriptionFailure extends FeatureFailure {
  final dynamic exception;

  StoreSubscriptionFailure(this.exception);

  @override
  List<Object> get props => [exception];
}