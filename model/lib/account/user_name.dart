import 'package:equatable/equatable.dart';

class UserName with EquatableMixin {
  final String userName;

  UserName(this.userName);

  @override
  List<Object> get props => [userName];
}