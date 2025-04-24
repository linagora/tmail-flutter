import 'package:flutter/material.dart';

class CheckboxSemantics extends StatelessWidget {
  final Widget child;
  final String label;
  final bool value;

  const CheckboxSemantics({
    super.key,
    required this.child,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      checked: true,
      value: '$value',
      child: child,
    );
  }
}
