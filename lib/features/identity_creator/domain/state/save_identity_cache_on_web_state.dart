import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SavingIdentityCacheOnWeb extends LoadingState {}

class SaveIdentityCacheOnWebSuccess extends UIState {}

class SaveIdentityCacheOnWebFailure extends FeatureFailure {
  SaveIdentityCacheOnWebFailure({super.exception});
}