import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:json_annotation/json_annotation.dart';


part 'get_email_recovery_action_response.g.dart';

@IdConverter()
@JsonSerializable()
class GetEmailRecoveryActionResponse extends GetResponseNoAccountId<EmailRecoveryAction> {
  GetEmailRecoveryActionResponse(
    List<EmailRecoveryAction> list,
    List<Id>? notFound
  ) : super(list, notFound);

  factory GetEmailRecoveryActionResponse.fromJson(Map<String, dynamic> json) => _$GetEmailRecoveryActionResponseFromJson(json);

  static GetEmailRecoveryActionResponse deserialize(Map<String, dynamic> json) {
    return GetEmailRecoveryActionResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetEmailRecoveryActionResponseToJson(this);

  @override
  List<Object?> get props => [list, notFound];
}