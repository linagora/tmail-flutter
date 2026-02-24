import 'package:equatable/equatable.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

abstract class VerifyNameException extends AppBaseException
    with EquatableMixin {
  static const emptyName = 'The name cannot be empty!';
  static const duplicatedName = 'The name already exists!';
  static const nameContainSpecialCharacter =
      'The name cannot contain special characters';
  static const emailAddressInvalid = 'The email address invalid';
  static const spaceOnlyWithinName = 'The name cannot contain only spaces';

  const VerifyNameException(super.message);

  @override
  List<Object?> get props => [message, exceptionName];
}

class EmptyNameException extends VerifyNameException {
  const EmptyNameException() : super(VerifyNameException.emptyName);

  @override
  String get exceptionName => 'EmptyNameException';
}

class DuplicatedNameException extends VerifyNameException {
  const DuplicatedNameException() : super(VerifyNameException.duplicatedName);

  @override
  String get exceptionName => 'DuplicatedNameException';
}

class SpecialCharacterException extends VerifyNameException {
  const SpecialCharacterException()
      : super(VerifyNameException.nameContainSpecialCharacter);

  @override
  String get exceptionName => 'SpecialCharacterException';
}

class EmailAddressInvalidException extends VerifyNameException {
  const EmailAddressInvalidException()
      : super(VerifyNameException.emailAddressInvalid);

  @override
  String get exceptionName => 'EmailAddressInvalidException';
}

class NameWithSpaceOnlyException extends VerifyNameException {
  const NameWithSpaceOnlyException()
      : super(VerifyNameException.spaceOnlyWithinName);

  @override
  String get exceptionName => 'NameWithSpaceOnlyException';
}
