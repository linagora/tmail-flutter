import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:model/model.dart';

class AccountRequest with EquatableMixin {
  final UserName? userName;
  final Password? password;
  final Token? token;
  final AuthenticationType authenticationType;

  AccountRequest({
    this.userName,
    this.password,
    this.token,
    this.authenticationType = AuthenticationType.none,
  });

  String get basicAuth =>
      'Basic ${base64Encode(utf8.encode('${userName?.userName}:${password?.value}'))}';

  String get bearerToken => 'Bearer ${token?.token}';

  @override
  List<Object?> get props => [userName, password];
}