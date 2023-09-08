// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RulesFilterInputFieldArguments with EquatableMixin {
  final FocusNode focusNode;
  final String errorText;
  final TextEditingController controller;

  RulesFilterInputFieldArguments({
    required this.focusNode,
    required this.errorText,
    required this.controller,
  });
  
  @override
  List<Object?> get props => [
    focusNode,
    errorText,
    controller,
  ];
}
