import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';

extension EitherViewStateExtension on Either<Failure, Success> {
  dynamic foldSuccessWithResult<T>() {
    return fold(
      (failure) => failure,
      (success) => success is T ? success as T : null,
    );
  }
}