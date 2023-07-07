import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreSessionLoading extends UIState {}

class StoreSessionSuccess extends UIState {}

class StoreSessionFailure extends FeatureFailure {

  StoreSessionFailure(dynamic exception) : super(exception: exception);
}