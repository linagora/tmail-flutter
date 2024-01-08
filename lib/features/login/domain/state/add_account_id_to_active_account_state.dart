import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class AddAccountIdToActiveAccountLoading extends LoadingState {}

class AddAccountIdToActiveAccountSuccess extends UIState {}

class AddAccountIdToActiveAccountFailure extends FeatureFailure {

  AddAccountIdToActiveAccountFailure(dynamic exception) : super(exception: exception);
}