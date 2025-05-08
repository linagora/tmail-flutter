import 'package:flutter/material.dart';

class TextFieldSemantics extends StatelessWidget {
  final Widget child;
  final String label;
  final String value;

  const TextFieldSemantics({
    super.key,
    required this.child,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(label: label, value: value, container: true, child: child);
  }
}
