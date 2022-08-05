import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/get_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/tmail_rule.dart';

part 'get_rule_filter_response.g.dart';

@StateConverter()
@AccountIdConverter()
@IdConverter()
@JsonSerializable()
class GetRuleFilterResponse extends GetResponse<TMailRule> {
  GetRuleFilterResponse(AccountId accountId, State state, List<TMailRule> list, List<Id>? notFound) : super(accountId, state, list, notFound);

  factory GetRuleFilterResponse.fromJson(Map<String, dynamic> json) => _$GetRuleFilterResponseFromJson(json);

  static GetRuleFilterResponse deserialize(Map<String, dynamic> json) {
    return GetRuleFilterResponse.fromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetRuleFilterResponseToJson(this);

  @override
  List<Object?> get props => [accountId, state, list, notFound];
}