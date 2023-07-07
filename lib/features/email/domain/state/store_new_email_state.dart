import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreNewEmailLoading extends UIState {}

class StoreNewEmailSuccess extends UIState {}

class StoreNewEmailFailure extends FeatureFailure {

  StoreNewEmailFailure(dynamic exception) : super(exception: exception);
}