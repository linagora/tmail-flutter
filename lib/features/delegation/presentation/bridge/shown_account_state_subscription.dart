import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/switch_attempt_stamp.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';

typedef OnViewResult = void Function(Either<Failure, Success> viewResult);
typedef OnViewError = void Function(dynamic error, StackTrace stackTrace);
typedef OnViewDone = void Function();
typedef OnStaleViewResult = void Function({Either<Failure, Success>? viewResult, Object? error});
typedef OnSubscriptionEnded = void Function(ShownAccountStateSubscription subscription);

class ShownAccountStateSubscription {
  final SwitchAttemptStamp stamp;
  final OnViewResult _onData;
  final OnViewError _onError;
  final OnViewDone _onDone;
  final OnStaleViewResult _onStale;
  final OnSubscriptionEnded _onEnded;
  final _result = Completer<ShownAccountLoadResult>();

  StreamSubscription<Either<Failure, Success>>? _subscription;
  Either<Failure, Success>? _lastResult;
  Object? _streamError;
  StackTrace? _streamStackTrace;

  ShownAccountStateSubscription({
    required this.stamp,
    required OnViewResult onData,
    required OnViewError onError,
    required OnViewDone onDone,
    required OnStaleViewResult onStale,
    required OnSubscriptionEnded onEnded,
  })  : _onData = onData,
        _onError = onError,
        _onDone = onDone,
        _onStale = onStale,
        _onEnded = onEnded;

  ShownAccountLoad get load => ShownAccountLoad(attemptId: stamp.attemptId, result: _result.future);

  void listen(Stream<Either<Failure, Success>> viewResults) {
    _subscription = viewResults.listen(_handleData, onError: _handleError, onDone: _handleDone);
  }

  void cancel() {
    // A request that fails after the cancel ends the load with its error in the cancel future.
    _subscription?.cancel().catchError((Object error) => _onStale(error: error));
    _end(const ShownAccountLoadDropped());
  }

  void _handleData(Either<Failure, Success> viewResult) {
    if (_cancelIfStale()) {
      _onStale(viewResult: viewResult);
      return;
    }
    _lastResult = viewResult;
    _onData(viewResult);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (_cancelIfStale()) {
      _onStale(error: error);
      return;
    }
    _streamError = error;
    _streamStackTrace = stackTrace;
    _onError(error, stackTrace);
  }

  void _handleDone() {
    if (_cancelIfStale()) return;
    try {
      _onDone();
    } finally {
      _end(_doneResult());
    }
  }

  bool _cancelIfStale() {
    if (stamp.isCurrent) return false;
    cancel();
    return true;
  }

  ShownAccountLoadResult _doneResult() {
    final streamError = _streamError;
    if (streamError != null) return ShownAccountLoadFailed(streamError, _streamStackTrace);

    final failure = _lastResult?.fold((failure) => failure, (_) => null);
    return failure != null ? ShownAccountLoadFailed(failure) : const ShownAccountLoaded();
  }

  void _end(ShownAccountLoadResult loadResult) {
    if (_result.isCompleted) return;
    _result.complete(loadResult);
    _onEnded(this);
  }
}
