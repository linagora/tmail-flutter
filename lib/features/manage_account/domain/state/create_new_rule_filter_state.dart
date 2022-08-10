import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class CreateNewRuleFilterSuccess extends UIState {

  final List<TMailRule> newListRules;

  CreateNewRuleFilterSuccess(this.newListRules);

  @override
  List<Object?> get props => [newListRules];
}

class CreateNewRuleFilterFailure extends FeatureFailure {
  final dynamic exception;

  CreateNewRuleFilterFailure(this.exception);

  @override
  List<Object> get props => [exception];
}