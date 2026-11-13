import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delegated_account.g.dart';

/// A delegation that lets me open [username]'s mailbox. [id] is the delegation id, not an account id.
@JsonSerializable(converters: [IdConverter()], createToJson: false)
class DelegatedAccount with EquatableMixin {
  final Id id;
  final String username;

  DelegatedAccount({required this.id, required this.username});

  factory DelegatedAccount.fromJson(Map<String, dynamic> json) =>
      _$DelegatedAccountFromJson(json);

  @override
  List<Object?> get props => [id, username];
}
