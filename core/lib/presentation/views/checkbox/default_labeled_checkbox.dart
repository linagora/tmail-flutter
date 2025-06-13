import 'package:core/presentation/views/checkbox/labeled_checkbox.dart';
import 'package:flutter/material.dart';

class DefaultLabeledCheckbox extends LabeledCheckbox {

  final Color activeColor;
  final FocusNode focusNode;

  const DefaultLabeledCheckbox({
    super.key,
    required super.label,
    required super.onChanged,
    required this.activeColor,
    required this.focusNode,
    super.value,
    super.gap,
    super.textStyle,
  });

  @override
  Widget get buildCheckboxWidget => Checkbox(
    value: value,
    activeColor: activeColor,
    visualDensity: VisualDensity.compact,
    focusNode: focusNode,
    onChanged: onChanged,
  );
}
