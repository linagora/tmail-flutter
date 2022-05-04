
import 'package:equatable/equatable.dart';

abstract class VerifyNameException extends Equatable implements Exception {
  static const emptyName = 'The name cannot be empty!';
  static const duplicatedName = 'The name already exists!';
  static const nameContainSpecialCharacter = 'The name cannot contain special characters';

  final String? message;

  const VerifyNameException(this.message);
}

class EmptyNameException extends VerifyNameException {
  const EmptyNameException() : super(VerifyNameException.emptyName);

  @override
  List<Object> get props => [];
}

class DuplicatedNameException extends VerifyNameException {
  const DuplicatedNameException() : super(VerifyNameException.duplicatedName);

  @override
  List<Object> get props => [];
}

class SpecialCharacterException extends VerifyNameException {
  const SpecialCharacterException() : super(VerifyNameException.nameContainSpecialCharacter);

  @override
  List<Object> get props => [];
}