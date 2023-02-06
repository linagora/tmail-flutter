import 'package:core/core.dart';

class LoadingSubscribeMailbox extends UIState {}

class SubscribeMailboxSuccess extends UIState {

  final bool subscribeMailbox;

  SubscribeMailboxSuccess(this.subscribeMailbox);

  @override
  List<Object?> get props => [subscribeMailbox];
}

class SubscribeMailboxFailure extends FeatureFailure {
  final dynamic exception;

  SubscribeMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}