import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import '../entity/workplace_intent.dart';

class CreatingWorkplaceIntent extends LoadingState {}

class CreateWorkplaceIntentSuccess extends UIState {
  final WorkplaceIntent intent;
  CreateWorkplaceIntentSuccess(this.intent);

  @override
  List<Object?> get props => [intent];
}

class CreateWorkplaceIntentFailure extends FeatureFailure {
  CreateWorkplaceIntentFailure({super.exception});

  @override
  List<Object?> get props => [exception];
}

class ExchangingWorkplaceToken extends LoadingState {}

class ExchangeWorkplaceTokenSuccess extends UIState {
  final String accessToken;
  ExchangeWorkplaceTokenSuccess(this.accessToken);

  @override
  List<Object?> get props => [accessToken];
}

class ExchangeWorkplaceTokenFailure extends FeatureFailure {
  ExchangeWorkplaceTokenFailure({super.exception});

  @override
  List<Object?> get props => [exception];
}
