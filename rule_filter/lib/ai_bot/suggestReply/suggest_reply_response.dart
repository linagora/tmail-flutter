import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/method/method.dart';
import 'package:jmap_dart_client/jmap/core/method/method_response.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggest_reply_response.g.dart';

@JsonSerializable()
class SuggestReplyResponse extends ResponseRequiringAccountId {
  final String suggestion;

  SuggestReplyResponse(AccountId accountId, this.suggestion) : super(accountId);

  factory SuggestReplyResponse.fromJson(Map<String, dynamic> json) =>
      _$SuggestReplyResponseFromJson(json);

  static SuggestReplyResponse deserialize(Map<String, dynamic> json) {
    return SuggestReplyResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$SuggestReplyResponseToJson(this);

  @override
  List<Object?> get props => [accountId, suggestion];
}
