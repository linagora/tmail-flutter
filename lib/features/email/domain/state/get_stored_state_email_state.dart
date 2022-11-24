
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class GetStoredEmailStateSuccess extends UIState {

  final jmap.State state;

  GetStoredEmailStateSuccess(this.state);

  @override
  List<Object> get props => [state];
}

class NotFoundEmailState extends FeatureFailure {

  NotFoundEmailState();

  @override
  List<Object> get props => [];
}

class GetStoredEmailStateFailure extends FeatureFailure {
  final dynamic exception;

  GetStoredEmailStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}