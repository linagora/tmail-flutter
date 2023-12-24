import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/user_name_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/token_oidc.dart';

part 'keychain_sharing_session.g.dart';

@UserNameConverter()
@AccountIdConverter()
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class KeychainSharingSession with EquatableMixin {
  AccountId accountId;
  UserName userName;
  AuthenticationType authenticationType;
  String apiUrl;
  String? emailState;
  TokenOIDC? tokenOIDC;
  String? basicAuth;

  KeychainSharingSession({
    required this.accountId,
    required this.userName,
    required this.authenticationType,
    required this.apiUrl,
    this.emailState,
    this.tokenOIDC,
    this.basicAuth,
  });

  factory KeychainSharingSession.fromJson(Map<String, dynamic> json) => _$KeychainSharingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$KeychainSharingSessionToJson(this);

  @override
  List<Object?> get props => [
    accountId,
    userName,
    authenticationType,
    apiUrl,
    emailState,
    tokenOIDC,
    basicAuth,
  ];
}
