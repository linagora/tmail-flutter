import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:equatable/equatable.dart';

class NotFoundInWebSessionException extends AppBaseException
    with EquatableMixin {
  const NotFoundInWebSessionException({String? errorMessage})
      : super(errorMessage);

  @override
  String get exceptionName => 'NotFoundInWebSessionException';

  @override
  List<Object?> get props => [message, exceptionName];
}

class NotMatchInWebSessionException extends AppBaseException
    with EquatableMixin {
  const NotMatchInWebSessionException() : super('Session data does not match');

  @override
  String get exceptionName => 'NotMatchInWebSessionException';

  @override
  List<Object?> get props => [message, exceptionName];
}

class SaveToWebSessionFailException extends AppBaseException
    with EquatableMixin {
  const SaveToWebSessionFailException({String? errorMessage})
      : super(errorMessage);

  @override
  String get exceptionName => 'SaveToWebSessionFailException';

  @override
  List<Object?> get props => [message, exceptionName];
}

class CannotOpenNewWindowException extends AppBaseException {
  const CannotOpenNewWindowException([super.message]);

  @override
  String get exceptionName => 'CannotOpenNewWindowException';
}
