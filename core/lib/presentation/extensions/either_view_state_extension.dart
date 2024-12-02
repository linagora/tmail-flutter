import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';

typedef OnFailureCallback = void Function(Failure? failure);
typedef OnSuccessCallback<T> = void Function(T success);

extension EitherViewStateExtension on Either<Failure, Success> {
  void foldSuccess<T>({
    required OnSuccessCallback<T> onSuccess,
    required OnFailureCallback onFailure,
  }) {
    fold(onFailure,
        (success) => success is T ? onSuccess(success as T) : onFailure(null));
  }
}
