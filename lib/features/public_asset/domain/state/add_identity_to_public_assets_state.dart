import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class AddingIdentityToPublicAssetsState extends LoadingState {}

class AddIdentityToPublicAssetsSuccessState extends UIState {}

class AddIdentityToPublicAssetsFailureState extends FeatureFailure {
  AddIdentityToPublicAssetsFailureState({super.exception});
}