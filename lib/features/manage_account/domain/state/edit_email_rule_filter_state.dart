import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class EditEmailRuleFilterSuccess extends UIState {

  final List<TMailRule> listRulesUpdated;

  EditEmailRuleFilterSuccess(this.listRulesUpdated);

  @override
  List<Object?> get props => [listRulesUpdated];
}

class EditEmailRuleFilterFailure extends FeatureFailure {
  final dynamic exception;

  EditEmailRuleFilterFailure(this.exception);

  @override
  List<Object> get props => [exception];
}