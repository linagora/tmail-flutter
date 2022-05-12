import 'package:contact/contact/model/tmail_contact.dart';
import 'package:contact/core/method/response/autocomplete_response.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:json_annotation/json_annotation.dart';

part 'autocomplete_tmail_contact_response.g.dart';

@UnsignedIntNullableConverter()
@AccountIdConverter()
@JsonSerializable()
class AutoCompleteTMailContactResponse extends AutoCompleteResponse<TMailContact> {

  AutoCompleteTMailContactResponse(
      AccountId accountId,
      List<TMailContact> list,
      UnsignedInt? limit
  ) : super(accountId, list, limit);

  factory AutoCompleteTMailContactResponse.fromJson(Map<String, dynamic> json) =>
      _$AutoCompleteTMailContactResponseFromJson(json);

  static AutoCompleteTMailContactResponse deserialize(Map<String, dynamic> json) {
    return AutoCompleteTMailContactResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$AutoCompleteTMailContactResponseToJson(this);

  @override
  List<Object?> get props => [accountId, list, limit];
}