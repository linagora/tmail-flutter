import 'package:core/core.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class DeleteEmailRuleSuccess extends UIState {
  final List<TMailRule>? rules;

  DeleteEmailRuleSuccess(this.rules);

  @override
  List<Object?> get props => [rules];
}

class DeleteEmailRuleFailure extends FeatureFailure {
  final dynamic exception;

  DeleteEmailRuleFailure(this.exception);

  @override
  List<Object> get props => [exception];
}