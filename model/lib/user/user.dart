import 'package:equatable/equatable.dart';
import 'package:model/user/user_id.dart';

class User with EquatableMixin {

  final UserId userId;
  final String firstName;
  final String lastName;

  User(
    this.userId,
    this.firstName,
    this.lastName,
  );

  @override
  List<Object> get props => [
    userId,
    firstName,
    lastName,
  ];
}