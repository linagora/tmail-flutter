
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSubscriptionLoading extends UIState {}

class StoreSubscriptionSuccess extends UIState {}

class StoreSubscriptionFailure extends FeatureFailure {

  StoreSubscriptionFailure(dynamic exception) : super(exception: exception);
}