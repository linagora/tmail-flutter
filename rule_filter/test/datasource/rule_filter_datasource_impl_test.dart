import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rule_filter/data/datasource_impl/rule_filter_datasource_impl.dart';
import 'package:rule_filter/data/network/rule_filter_api.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_filter.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

import 'rule_filter_datasource_impl_test.mocks.dart';

@GenerateMocks([RuleFilterAPI])
void main() {
  final expectRuleFilter1 = RuleFilter(
    id: RuleFilterIdSingleton.ruleFilterIdSingleton,
    rules: [
      TMailRule(
        name: 'My first rule',
        condition: RuleCondition(
          value: 'question',
          comparator: Comparator.contains,
          field: Field.subject,
        ),
        action: RuleAction(
          appendIn: RuleAppendIn(
            mailboxIds: [
              MailboxId(Id('42')),
            ],
          ),
        ),
      )
    ],
  );


  group('rule_filter_datasource_impl_test', () {
    late RuleFilterAPI _ruleFilterAPI;
    late RuleFilterDataSourceImpl _ruleFilterDataSourceImpl;

    setUp(() {
      _ruleFilterAPI = MockRuleFilterAPI();
      _ruleFilterDataSourceImpl = RuleFilterDataSourceImpl(_ruleFilterAPI);
    });

    test('getListTMailRule should return success with valid data', () async {
      when(_ruleFilterAPI.getListTMailRule(AccountId(Id(
              '0eacc7a5c74b27ab36a823bc5c34da36e16c093705f241d6ed5f48ee73a4ecfb'))))
          .thenAnswer((_) async => expectRuleFilter1.rules);

      final result = await _ruleFilterDataSourceImpl.getListTMailRule(AccountId(Id(
          '0eacc7a5c74b27ab36a823bc5c34da36e16c093705f241d6ed5f48ee73a4ecfb')));
      expect(result, expectRuleFilter1.rules);
    });
  });
}
