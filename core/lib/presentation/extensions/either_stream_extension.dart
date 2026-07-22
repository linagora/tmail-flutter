import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';

typedef ToFailureCallback = Failure Function(Object error, StackTrace stackTrace);

extension EitherStreamExtension on Stream<Either<Failure, Success>> {
  /// Converts an error raised by this stream into a [Left] event.
  ///
  /// `yield*` forwards a delegated stream's error straight to the subscriber,
  /// bypassing the enclosing try/catch of the `async*` function. That kills the
  /// subscription, so callers never receive a failure state and stay stuck on
  /// loading. Turning the error into a value keeps everything on the single
  /// Either channel, which is what consumers already listen for.
  ///
  /// The stream is left open afterwards: a source that reports an error and
  /// keeps going can still deliver later events.
  Stream<Either<Failure, Success>> mapErrorToLeft(ToFailureCallback toFailure) {
    return this.cast<Either<Failure, Success>>().transform(
      StreamTransformer<Either<Failure, Success>, Either<Failure, Success>>.fromHandlers(
        handleError: (error, stackTrace, sink) => sink.add(
          Left<Failure, Success>(toFailure(error, stackTrace)),
        ),
      ),
    );
  }
}
