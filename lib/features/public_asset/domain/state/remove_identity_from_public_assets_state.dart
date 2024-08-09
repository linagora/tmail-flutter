import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RemovingIdentityFromPublicAssetsState extends LoadingState {}

class RemoveIdentityFromPublicAssetsSuccessState extends UIState {}

class RemoveIdentityFromPublicAssetsFailureState extends FeatureFailure {
  RemoveIdentityFromPublicAssetsFailureState({super.exception});
}

class NotFoundAnyPublicAssetsFailureState extends FeatureFailure {
  NotFoundAnyPublicAssetsFailureState({super.exception});
}