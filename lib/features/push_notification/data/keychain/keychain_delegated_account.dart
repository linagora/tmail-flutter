import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'keychain_delegated_account.g.dart';

@MailboxIdConverter()
@AccountIdConverter()
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class KeychainDelegatedAccount with EquatableMixin {
  final AccountId accountId;
  final String? emailDeliveryState;
  final List<MailboxId>? mailboxIdsBlockNotification;

  KeychainDelegatedAccount({
    required this.accountId,
    this.emailDeliveryState,
    this.mailboxIdsBlockNotification,
  });

  factory KeychainDelegatedAccount.fromJson(Map<String, dynamic> json) =>
      _$KeychainDelegatedAccountFromJson(json);

  Map<String, dynamic> toJson() => _$KeychainDelegatedAccountToJson(this);

  @override
  List<Object?> get props => [
        accountId,
        emailDeliveryState,
        mailboxIdsBlockNotification,
      ];
}
