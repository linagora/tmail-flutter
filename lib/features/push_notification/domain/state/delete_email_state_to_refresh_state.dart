
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteEmailStateToRefreshLoading extends UIState {}

class DeleteEmailStateToRefreshSuccess extends UIState {

  DeleteEmailStateToRefreshSuccess();

  @override
  List<Object> get props => [];
}

class DeleteEmailStateToRefreshFailure extends FeatureFailure {
  final dynamic exception;

  DeleteEmailStateToRefreshFailure(this.exception);

  @override
  List<Object> get props => [exception];
}