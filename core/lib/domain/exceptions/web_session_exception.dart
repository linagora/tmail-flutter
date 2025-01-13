import 'package:equatable/equatable.dart';

class NotFoundInWebSessionException with EquatableMixin implements Exception {
  final String? errorMessage;

  NotFoundInWebSessionException({this.errorMessage});

  @override
  List<Object> get props => [];
}

class NotMatchInWebSessionException with EquatableMixin implements Exception {
  const NotMatchInWebSessionException();

  @override
  List<Object> get props => [];
}

class SaveToWebSessionFailException with EquatableMixin implements Exception {
  final String? errorMessage;

  SaveToWebSessionFailException({this.errorMessage});

  @override
  List<Object> get props => [];
}

class CannotOpenNewWindowException implements Exception {}
