import 'package:equatable/equatable.dart';

class UserProfile with EquatableMixin {

  final String email;

  UserProfile(this.email);

  String getAvatarText() {
    return email[0].toUpperCase();
  }

  @override
  List<Object> get props => [email];
}