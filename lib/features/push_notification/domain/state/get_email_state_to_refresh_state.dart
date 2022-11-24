
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class GetEmailStateToRefreshLoading extends UIState {}

class GetEmailStateToRefreshSuccess extends UIState {

  final jmap.State storedState;

  GetEmailStateToRefreshSuccess(this.storedState);

  @override
  List<Object> get props => [storedState];
}

class GetEmailStateToRefreshFailure extends FeatureFailure {
  final dynamic exception;

  GetEmailStateToRefreshFailure(this.exception);

  @override
  List<Object> get props => [exception];
}