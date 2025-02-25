import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract class Failure with EquatableMixin {

  @override
  bool? get stringify => true;
}

abstract class FeatureFailure extends Failure {
  final dynamic exception;
  final Stream<Either<Failure, Success>>? onRetry;

  FeatureFailure({this.exception, this.onRetry});

  @override
  List<Object?> get props => [exception, onRetry];
}
