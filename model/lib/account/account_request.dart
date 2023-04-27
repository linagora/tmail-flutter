import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/oidc/token.dart';

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

  String get basicAuth => 'Basic ${base64Encode(utf8.encode('${userName?.value}:${password?.value}'))}';

  String get bearerToken => 'Bearer ${token?.token}';

  @override
  List<Object?> get props => [userName, password];
}