
import 'package:equatable/equatable.dart';

abstract class VerifyNameException extends Equatable implements Exception {
  static const EmptyName = 'The name cannot be empty!';
  static const DuplicatedName = 'The name already exists!';
  static const NameContainSpecialCharacter = 'The name cannot contain special characters';

  final String? message;

  VerifyNameException(this.message);
}

class EmptyNameException extends VerifyNameException {
  EmptyNameException() : super(VerifyNameException.EmptyName);

  @override
  List<Object> get props => [];
}

class DuplicatedNameException extends VerifyNameException {
  DuplicatedNameException() : super(VerifyNameException.DuplicatedName);

  @override
  List<Object> get props => [];
}

class SpecialCharacterException extends VerifyNameException {
  SpecialCharacterException() : super(VerifyNameException.NameContainSpecialCharacter);

  @override
  List<Object> get props => [];
}