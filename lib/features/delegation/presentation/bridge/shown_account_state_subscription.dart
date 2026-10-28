import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/switch_attempt_stamp.dart';

typedef OnViewResult = void Function(Either<Failure, Success> viewResult);
typedef OnViewError = void Function(dynamic error, StackTrace stackTrace);
typedef OnViewDone = void Function();
typedef OnSubscriptionEnded = void Function(ShownAccountStateSubscription subscription);

class ShownAccountStateSubscription {
  final SwitchAttemptStamp stamp;
  final OnViewResult _onData;
  final OnViewError _onError;
  final OnViewDone _onDone;
  final OnSubscriptionEnded _onEnded;

  StreamSubscription<Either<Failure, Success>>? _subscription;
  bool _ended = false;

  ShownAccountStateSubscription({
    required this.stamp,
    required OnViewResult onData,
    required OnViewError onError,
    required OnViewDone onDone,
    required OnSubscriptionEnded onEnded,
  })  : _onData = onData,
        _onError = onError,
        _onDone = onDone,
        _onEnded = onEnded;

  void listen(Stream<Either<Failure, Success>> viewResults) {
    _subscription = viewResults.listen(_handleData, onError: _handleError, onDone: _handleDone);
  }

  void cancel() {
    _subscription?.cancel();
    _end();
  }

  void _handleData(Either<Failure, Success> viewResult) {
    if (_cancelIfStale()) return;
    _onData(viewResult);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (_cancelIfStale()) return;
    _onError(error, stackTrace);
  }

  void _handleDone() {
    if (_cancelIfStale()) return;
    _end();
    _onDone();
  }

  bool _cancelIfStale() {
    if (stamp.isCurrent) return false;
    cancel();
    return true;
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    _onEnded(this);
  }
}
