import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';

class BasicAuth with EquatableMixin {
  final UserName userName;
  final Password password;

  BasicAuth(this.userName, this.password);

  @override
  List<Object?> get props => [userName, password];
}