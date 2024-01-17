import 'package:equatable/equatable.dart';

class AuthorizationCode with EquatableMixin {
  final String value;

  const AuthorizationCode({
    required this.value
  });

  @override
  List<Object?> get props => [value];

}