
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

part 'presentation_account_response.g.dart';

@PresentationEmailAddressConverter()
@JsonSerializable()
class PresentationAccountResponse with EquatableMixin {
  final List<PresentationEmailAddress>? emails;
  final int preferredEmailIndex;
  final AccountType type;

  PresentationAccountResponse(this.emails, this.preferredEmailIndex, this.type);

  factory PresentationAccountResponse.fromJson(Map<String, dynamic> json) => _$PresentationAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationAccountResponseToJson(this);

  @override
  List<Object?> get props => [emails, preferredEmailIndex, type];
}

extension PresentationAccountResponseExtension on PresentationAccountResponse {
  PresentationAccount toPresentationAccount() {
    return PresentationAccount(emails ?? [], preferredEmailIndex, type);
  }
}