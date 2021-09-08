import 'package:equatable/equatable.dart';
import 'package:model/model.dart';

class AccountRequest with EquatableMixin {
  final UserName userName;
  final Password password;

  AccountRequest(this.userName, this.password);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': userName.userName,
    'password': password.value,
  };

  @override
  List<Object> get props => [userName, password];
}