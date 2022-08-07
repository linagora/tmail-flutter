import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/properties_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/method/request/get_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/request/result_reference.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:rule_filter/rule_filter/converter/rule_id_converter.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';

part 'get_rule_filter_method.g.dart';

@IdConverter()
@RuleIdConverter()
@AccountIdConverter()
@PropertiesConverter()
@JsonSerializable(explicitToJson: true)
class GetRuleFilterMethod extends GetMethod {
  GetRuleFilterMethod(AccountId accountId) : super(accountId);

  @override
  MethodName get methodName => MethodName('Filter/get');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
    capabilityRuleFilter
  };

  @override
  List<Object?> get props => [methodName, accountId, ids, requiredCapabilities];

  factory GetRuleFilterMethod.fromJson(Map<String, dynamic> json) => _$GetRuleFilterMethodFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetRuleFilterMethodToJson(this);
}