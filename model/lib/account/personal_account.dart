import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';

class PersonalAccount with EquatableMixin {
  final String id;
  final AuthenticationType authenticationType;
  final bool isSelected;
  final AccountId? accountId;
  final String? apiUrl;
  final UserName? userName;

  PersonalAccount(
    this.id,
    this.authenticationType,
    {
      required this.isSelected,
      this.accountId,
      this.apiUrl,
      this.userName
    }
  );

  @override
  List<Object?> get props => [
    id,
    authenticationType,
    isSelected,
    accountId,
    apiUrl,
    userName
  ];
}