import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';

class InitializingWebSocketPushChannel extends LoadingState {}

class WebSocketPushStateReceived extends UIState {
  final StateChange? stateChange;

  WebSocketPushStateReceived(this.stateChange);

  @override
  List<Object?> get props => [stateChange];
}

class WebSocketConnectionFailed extends FeatureFailure {

  WebSocketConnectionFailed({super.exception});
}