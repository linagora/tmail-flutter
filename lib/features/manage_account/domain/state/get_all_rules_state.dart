import 'package:core/core.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class GetAllRulesSuccess extends UIState {
  final List<TMailRule>? rules;

  GetAllRulesSuccess(this.rules);

  @override
  List<Object?> get props => [rules];
}

class GetAllRulesFailure extends FeatureFailure {
  final dynamic exception;

  GetAllRulesFailure(this.exception);

  @override
  List<Object> get props => [exception];
}