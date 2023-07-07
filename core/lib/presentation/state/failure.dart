import 'package:equatable/equatable.dart';

abstract class Failure with EquatableMixin {

  @override
  bool? get stringify => true;
}

abstract class FeatureFailure extends Failure {
  final dynamic exception;

  FeatureFailure({this.exception});

  @override
  List<Object?> get props => [exception];
}
