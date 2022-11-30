
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreMailboxStateToRefreshLoading extends UIState {}

class StoreMailboxStateToRefreshSuccess extends UIState {

  StoreMailboxStateToRefreshSuccess();

  @override
  List<Object> get props => [];
}

class StoreMailboxStateToRefreshFailure extends FeatureFailure {
  final dynamic exception;

  StoreMailboxStateToRefreshFailure(this.exception);

  @override
  List<Object> get props => [exception];
}