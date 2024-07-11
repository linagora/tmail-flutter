import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/basic_auth.dart';
import 'package:model/oidc/token_oidc.dart';

class PersonalAccount with EquatableMixin {
  final String id;
  final AuthenticationType authenticationType;
  final bool isSelected;
  final AccountId? accountId;
  final String? apiUrl;
  final UserName? userName;
  final String baseUrl;
  final BasicAuth? basicAuth;
  final TokenOIDC? tokenOidc;

  PersonalAccount({
    required this.id,
    required this.authenticationType,
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
    authenticationType,
    isSelected,
    accountId,
    apiUrl,
    userName,
    baseUrl,
    basicAuth,
    tokenOidc,
  ];
}