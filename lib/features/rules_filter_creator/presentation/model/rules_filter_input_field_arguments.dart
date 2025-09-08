import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RulesFilterInputFieldArguments with EquatableMixin {
  final FocusNode focusNode;
  final TextEditingController controller;
  final String? errorText;

  RulesFilterInputFieldArguments({
    required this.focusNode,
    required this.controller,
    this.errorText,
  });
  
  @override
  List<Object?> get props => [
    focusNode,
    controller,
    errorText,
  ];
}
