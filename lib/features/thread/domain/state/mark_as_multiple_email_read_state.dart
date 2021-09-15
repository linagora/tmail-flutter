import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

class MarkAsMultipleEmailReadAllSuccess extends UIState {
  final List<Either<Failure, Success>> resultList;

  MarkAsMultipleEmailReadAllSuccess(this.resultList);

  @override
  List<Object?> get props => [resultList];
}

class MarkAsMultipleEmailReadAllFailure extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  MarkAsMultipleEmailReadAllFailure(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class MarkAsMultipleEmailReadHasSomeEmailFailure extends UIState {
  final List<Either<Failure, Success>> resultList;

  MarkAsMultipleEmailReadHasSomeEmailFailure(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final exception;

  MarkAsMultipleEmailReadFailure(this.exception);

  @override
  List<Object> get props => [exception];
}