
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreEmailStateToRefreshLoading extends UIState {}

class StoreEmailStateToRefreshSuccess extends UIState {}

class StoreEmailStateToRefreshFailure extends FeatureFailure {

  StoreEmailStateToRefreshFailure(dynamic exception) : super(exception: exception);
}