
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

extension ListTMailRuleExtensions on List<TMailRule> {

  List<TMailRule> get withIds {
    return asMap()
      .map((key, rule) => MapEntry(
        key,
        rule.copyWith(id: RuleId(id: Id(key.toString())))))
      .values
      .toList();
  }
}