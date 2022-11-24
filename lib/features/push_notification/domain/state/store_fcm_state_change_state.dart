
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreEmailStateToRefreshLoading extends UIState {}

class StoreEmailStateToRefreshSuccess extends UIState {

  StoreEmailStateToRefreshSuccess();

  @override
  List<Object> get props => [];
}

class StoreEmailStateToRefreshFailure extends FeatureFailure {
  final dynamic exception;

  StoreEmailStateToRefreshFailure(this.exception);

  @override
  List<Object> get props => [exception];
}