import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';

extension InteractorResultExtension on Stream<Either<Failure, Success>> {
  /// Drains the interactor stream and returns its first [T] success.
  /// Failures rethrow their exception, reported downstream by
  /// DriveIntentMessageHandlerMixin._failWith, the single funnel.
  Future<T> firstSuccess<T extends Success>({
    required Exception Function() orElse,
  }) async {
    T? result;
    await for (final either in this) {
      either.fold(
        (failure) {
          throw failure is FeatureFailure ? failure.exception : orElse();
        },
        (success) {
          if (success is T) result = success;
        },
      );
    }
    if (result == null) throw orElse();
    return result!;
  }
}
