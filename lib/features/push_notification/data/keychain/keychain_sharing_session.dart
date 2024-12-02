import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_converter.dart';
import 'package:jmap_dart_client/http/converter/user_name_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/token_oidc.dart';

part 'keychain_sharing_session.g.dart';

@MailboxIdConverter()
@UserNameConverter()
@AccountIdConverter()
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class KeychainSharingSession with EquatableMixin {
  AccountId accountId;
  UserName userName;
  AuthenticationType authenticationType;
  String apiUrl;
  String? emailState;
  String? emailDeliveryState;
  TokenOIDC? tokenOIDC;
  String? basicAuth;
  String? tokenEndpoint;
  List<String>? oidcScopes;
  List<MailboxId>? mailboxIdsBlockNotification;
  bool isTWP;

  KeychainSharingSession({
    required this.accountId,
    required this.userName,
    required this.authenticationType,
    required this.apiUrl,
    this.emailState,
    this.emailDeliveryState,
    this.tokenOIDC,
    this.basicAuth,
    this.tokenEndpoint,
    this.oidcScopes,
    this.mailboxIdsBlockNotification,
    this.isTWP = false,
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
    emailDeliveryState,
    tokenOIDC,
    basicAuth,
    tokenEndpoint,
    oidcScopes,
    mailboxIdsBlockNotification,
    isTWP,
  ];
}