import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class GetAllRulesLoading extends LoadingState {}

class GetAllRulesSuccess extends UIState {
  final List<TMailRule> rules;

  GetAllRulesSuccess(this.rules);

  @override
  List<Object> get props => [rules];
}

class GetAllRulesFailure extends FeatureFailure {

  GetAllRulesFailure(dynamic exception) : super(exception: exception);
}