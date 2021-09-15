import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/email/read_actions.dart';

class MarkAsMultipleEmailReadAllSuccess extends UIState {
  final List<Either<Failure, Success>> resultList;
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllSuccess(this.resultList, this.readActions);

  @override
  List<Object?> get props => [resultList, readActions];
}

class MarkAsMultipleEmailReadAllFailure extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;
  final ReadActions readActions;

  MarkAsMultipleEmailReadAllFailure(this.resultList, this.readActions);

  @override
  List<Object> get props => [resultList, readActions];
}

class MarkAsMultipleEmailReadHasSomeEmailFailure extends UIState {
  final List<Either<Failure, Success>> resultList;
  final ReadActions readActions;

  MarkAsMultipleEmailReadHasSomeEmailFailure(this.resultList, this.readActions);

  @override
  List<Object> get props => [resultList, readActions];
}

class MarkAsMultipleEmailReadFailure extends FeatureFailure {
  final exception;
  final ReadActions readActions;

  MarkAsMultipleEmailReadFailure(this.exception, this.readActions);

  @override
  List<Object> get props => [exception, readActions];
}