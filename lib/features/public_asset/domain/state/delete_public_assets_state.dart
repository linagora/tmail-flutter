import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeletingPublicAssetsState extends LoadingState {}

class DeletePublicAssetsSuccessState extends UIState {}

class DeletePublicAssetsFailureState extends FeatureFailure {
  DeletePublicAssetsFailureState({super.exception});
}