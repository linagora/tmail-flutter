
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class GetStoredEmailDeliveryStateLoading extends UIState {}

class GetStoredEmailDeliveryStateSuccess extends UIState {

  final jmap.State state;

  GetStoredEmailDeliveryStateSuccess(this.state);

  @override
  List<Object> get props => [state];
}

class GetStoredEmailDeliveryStateFailure extends FeatureFailure {
  final dynamic exception;

  GetStoredEmailDeliveryStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}