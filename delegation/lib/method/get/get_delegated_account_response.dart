import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_delegated_account_response.g.dart';

/// James sends no `state` for this method, so the base without a required state is used.
@JsonSerializable(converters: [IdConverter()], createToJson: false)
class GetDelegatedAccountResponse extends GetResponseNoAccountId<DelegatedAccount> {
  GetDelegatedAccountResponse(super.list, super.notFound);

  factory GetDelegatedAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$GetDelegatedAccountResponseFromJson(json);

  static GetDelegatedAccountResponse deserialize(Map<String, dynamic> json) =>
      GetDelegatedAccountResponse.fromJson(json);

  @override
  List<Object?> get props => [list, notFound];
}
