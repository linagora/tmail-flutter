
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class GetMailboxStateToRefreshLoading extends UIState {}

class GetMailboxStateToRefreshSuccess extends UIState {

  final jmap.State storedState;

  GetMailboxStateToRefreshSuccess(this.storedState);

  @override
  List<Object> get props => [storedState];
}

class GetMailboxStateToRefreshFailure extends FeatureFailure {
  final dynamic exception;

  GetMailboxStateToRefreshFailure(this.exception);

  @override
  List<Object> get props => [exception];
}