import 'package:flutter/material.dart';

class IconSemantics extends StatelessWidget {
  final Widget child;
  final String label;

  const IconSemantics({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      image: true,
      child: child,
    );
  }
}
