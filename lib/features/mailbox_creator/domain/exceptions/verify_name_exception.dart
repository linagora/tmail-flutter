
import 'package:equatable/equatable.dart';

abstract class VerifyNameException extends Equatable implements Exception {
  static const emptyName = 'The name cannot be empty!';
  static const duplicatedName = 'The name already exists!';
  static const nameContainSpecialCharacter = 'The name cannot contain special characters';
  static const emailAddressInvalid = 'The email address invalid';
  static const spaceOnlyWithinName = 'The name cannot contain only spaces';

  final String? message;

  const VerifyNameException(this.message);

  @override
  List<Object?> get props => [message];
}

class EmptyNameException extends VerifyNameException {
  const EmptyNameException() : super(VerifyNameException.emptyName);
}

class DuplicatedNameException extends VerifyNameException {
  const DuplicatedNameException() : super(VerifyNameException.duplicatedName);
}

class SpecialCharacterException extends VerifyNameException {
  const SpecialCharacterException() : super(VerifyNameException.nameContainSpecialCharacter);
}

class EmailAddressInvalidException extends VerifyNameException {
  const EmailAddressInvalidException() : super(VerifyNameException.emailAddressInvalid);
}

class NameWithSpaceOnlyException extends VerifyNameException {
  const NameWithSpaceOnlyException() : super(VerifyNameException.spaceOnlyWithinName);
}