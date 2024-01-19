import 'package:equatable/equatable.dart';

class CanNotGetAuthenticationCodeException with EquatableMixin implements Exception {
  CanNotGetAuthenticationCodeException();

  @override
  List<Object?> get props => [];
}