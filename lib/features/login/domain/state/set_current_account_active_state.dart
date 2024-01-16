import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SetCurrentActiveAccountLoading extends LoadingState {}

class SetCurrentActiveAccountSuccess extends UIState {}

class SetCurrentActiveAccountFailure extends FeatureFailure {

  SetCurrentActiveAccountFailure(dynamic exception) : super(exception: exception);
}