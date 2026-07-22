import 'dart:async';

import 'package:core/presentation/extensions/either_stream_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFailure extends Failure {
  final String message;
  final StackTrace? stackTrace;

  TestFailure(this.message, {this.stackTrace});

  @override
  List<Object?> get props => [message];
}

class TestSuccess extends Success {
  final String data;

  TestSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

/// Mirrors how the interactors delegate to a repository stream: a loading state
/// is emitted first, then the source stream is forwarded with `yield*` from
/// inside a try/catch.
Stream<Either<Failure, Success>> interactorLike(
  Stream<Either<Failure, Success>> source, {
  required bool applyExtension,
}) async* {
  try {
    yield Right<Failure, Success>(TestSuccess('loading'));
    yield* applyExtension
        ? source.mapErrorToLeft((error, stackTrace) =>
            TestFailure('$error', stackTrace: stackTrace))
        : source;
  } catch (e) {
    yield Left<Failure, Success>(TestFailure('outer-catch'));
  }
}

Stream<Either<Failure, Success>> valueThenError(Object error) async* {
  yield Right<Failure, Success>(TestSuccess('first'));
  throw error;
}

void main() {
  group('EitherStreamExtension::mapErrorToLeft::test', () {
    test('Should forward values unchanged when the source raises no error', () async {
      final source = Stream<Either<Failure, Success>>.fromIterable([
        Right(TestSuccess('a')),
        Right(TestSuccess('b')),
      ]);

      final states = await source
          .mapErrorToLeft((error, _) => TestFailure('$error'))
          .toList();

      expect(states, [Right(TestSuccess('a')), Right(TestSuccess('b'))]);
    });

    test('Should convert an error raised by the source into a Left event', () async {
      final source = Stream<Either<Failure, Success>>.error(StateError('boom'));

      final states = await source
          .mapErrorToLeft((error, _) => TestFailure('$error'))
          .toList();

      expect(states, [Left<Failure, Success>(TestFailure('Bad state: boom'))]);
    });

    test('Should emit the Left in place, preserving the order of earlier values', () async {
      final states = await valueThenError(StateError('boom'))
          .mapErrorToLeft((error, _) => TestFailure('$error'))
          .toList();

      expect(states, [
        Right<Failure, Success>(TestSuccess('first')),
        Left<Failure, Success>(TestFailure('Bad state: boom')),
      ]);
    });

    test('Should keep the stream open so a source that errors then continues '
        'can still deliver later events', () async {
      final controller = StreamController<Either<Failure, Success>>();

      final future = controller.stream
          .mapErrorToLeft((error, _) => TestFailure('$error'))
          .toList();

      controller.add(Right(TestSuccess('before')));
      controller.addError(StateError('transient'));
      controller.add(Right(TestSuccess('after')));
      await controller.close();

      expect(await future, [
        Right<Failure, Success>(TestSuccess('before')),
        Left<Failure, Success>(TestFailure('Bad state: transient')),
        Right<Failure, Success>(TestSuccess('after')),
      ]);
    });

    test('Should handle a source whose runtime type is narrower than '
        'Stream<Either<Failure, Success>>', () async {
      // A generator yielding only Right values produces a Stream<Right<...>> at
      // runtime. StreamTransformer is not covariant in its input type, so the
      // element type has to be pinned before transforming.
      Stream<Right<Failure, Success>> narrowSource() async* {
        yield Right<Failure, Success>(TestSuccess('first'));
        throw StateError('boom');
      }

      final states = await narrowSource()
          .mapErrorToLeft((error, _) => TestFailure('$error'))
          .toList();

      expect(states, [
        Right<Failure, Success>(TestSuccess('first')),
        Left<Failure, Success>(TestFailure('Bad state: boom')),
      ]);
    });

    test('Should pass the stack trace of the error to the callback', () async {
      StackTrace? capturedStackTrace;

      await Stream<Either<Failure, Success>>.error(StateError('boom'))
          .mapErrorToLeft((error, stackTrace) {
            capturedStackTrace = stackTrace;
            return TestFailure('$error');
          })
          .toList();

      expect(capturedStackTrace, isNotNull);
    });

    test('Should keep an error raised by a delegated stream from escaping '
        'the try/catch of the enclosing async* function', () async {
      final states = await interactorLike(
        valueThenError(StateError('boom')),
        applyExtension: true,
      ).toList();

      expect(states, [
        Right<Failure, Success>(TestSuccess('loading')),
        Right<Failure, Success>(TestSuccess('first')),
        Left<Failure, Success>(TestFailure('Bad state: boom')),
      ]);
    });

    test('Should be required for that: without it the delegated error bypasses '
        'the enclosing try/catch and tears the stream down', () async {
      // Guards the premise of the extension. `yield*` hands a delegated
      // stream's error straight to the subscriber, so the catch never runs.
      expect(
        () => interactorLike(
          valueThenError(StateError('boom')),
          applyExtension: false,
        ).toList(),
        throwsStateError,
      );
    });
  });
}
