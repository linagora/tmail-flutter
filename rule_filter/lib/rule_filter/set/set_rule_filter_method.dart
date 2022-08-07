import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/set/set_method_properties_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/request/set_method.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class SetRuleFilterMethod extends SetMethod<List<TMailRule>> with OptionalUpdateRuleFilter<List<TMailRule>>{
  SetRuleFilterMethod(AccountId accountId) : super(accountId);

  @override
  MethodName get methodName => MethodName('Filter/set');

  @override
  Set<CapabilityIdentifier> get requiredCapabilities => {
        capabilityRuleFilter,
      };

  @override
  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{
      'accountId': const AccountIdConverter().toJson(accountId),
    };

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('ifInState', ifInState?.value);
    writeNotNull(
        'update',
        updateRuleFilter?.map((id, update) {
        final listJsonUpdatesRuleFilter = update.map((e) => e.toJson()).toList();
        return  SetMethodPropertiesConverter()
              .fromMapIdToJson(id, listJsonUpdatesRuleFilter);
        }));

    return val;
  }

  @override
  List<Object?> get props => [
        accountId,
        ifInState,
        update,
      ];
}

mixin OptionalUpdateRuleFilter<T> {
  @JsonKey(includeIfNull: false)
  Map<Id, T>? updateRuleFilter;

  void addUpdateRuleFilter(Map<Id, T> updatesRuleFilter) {
    updateRuleFilter ??= <Id, T>{};
    updateRuleFilter?.addAll(updatesRuleFilter);
  }
}
