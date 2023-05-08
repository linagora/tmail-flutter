

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class TaskSuccess extends Success {
  final dynamic result;

  TaskSuccess({this.result});

  @override
  List<Object?> get props => [result];
}

class TaskFailure extends Failure {
  final dynamic exception;

  TaskFailure({this.exception});

  @override
  List<Object?> get props => [exception];
}