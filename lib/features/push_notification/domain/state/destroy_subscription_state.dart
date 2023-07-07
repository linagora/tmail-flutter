import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DestroySubscriptionLoading extends UIState {}

class DestroySubscriptionSuccess extends UIState {

  final bool destroyedSubscription;

  DestroySubscriptionSuccess(this.destroyedSubscription);

  @override
  List<Object> get props => [destroyedSubscription];
}

class DestroySubscriptionFailure extends FeatureFailure {

  DestroySubscriptionFailure(dynamic exception) : super(exception: exception);
}