import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

abstract class FeatureFailure extends Failure {
  final dynamic exception;

  FeatureFailure({this.exception});
}
