import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/basic_auth.dart';
import 'package:model/oidc/token_oidc.dart';

class PersonalAccount with EquatableMixin {
  final String id;
  final AuthenticationType authType;
  final bool isSelected;
  final AccountId? accountId;
  final String? apiUrl;
  final UserName? userName;
  final String baseUrl;
  final TokenOIDC? tokenOidc;
  final BasicAuth? basicAuth;

  PersonalAccount({
    required this.id,
    required this.authType,
    required this.isSelected,
    required this.baseUrl,
    this.accountId,
    this.apiUrl,
    this.userName,
    this.basicAuth,
    this.tokenOidc,
  });

  @override
  List<Object?> get props => [
    id,
    authType,
    isSelected,
    baseUrl,
    accountId,
    apiUrl,
    userName,
    basicAuth,
    tokenOidc,
  ];
}