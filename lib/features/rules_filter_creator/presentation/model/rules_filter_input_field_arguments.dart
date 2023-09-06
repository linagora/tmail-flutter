// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RulesFilterInputFieldArguments with EquatableMixin {
  final FocusNode inputRuleConditionValueFocusNode;
  final String errorRuleConditionValue;
  final TextEditingController inputRuleConditionValueController;

  RulesFilterInputFieldArguments({
    required this.inputRuleConditionValueFocusNode,
    required this.errorRuleConditionValue,
    required this.inputRuleConditionValueController,
  });
  
  @override
  List<Object?> get props => [
    inputRuleConditionValueFocusNode,
    errorRuleConditionValue,
    inputRuleConditionValueController,
  ];
}
