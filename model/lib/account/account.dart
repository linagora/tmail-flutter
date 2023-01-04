import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/account/authentication_type.dart';

class Account with EquatableMixin {
  final String id;
  final AuthenticationType authenticationType;
  final bool isSelected;
  final AccountId? accountId;
  final String? apiUrl;

  Account(
    this.id,
    this.authenticationType,
    {
      required this.isSelected,
      this.accountId,
      this.apiUrl,
    }
  );

  @override
  List<Object?> get props => [
    id,
    authenticationType,
    isSelected,
    accountId,
    apiUrl
  ];
}