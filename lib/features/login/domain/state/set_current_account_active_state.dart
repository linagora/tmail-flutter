import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SetCurrentAccountActiveLoading extends LoadingState {}

class SetCurrentAccountActiveSuccess extends UIState {}

class SetCurrentAccountActiveFailure extends FeatureFailure {

  SetCurrentAccountActiveFailure(dynamic exception) : super(exception: exception);
}