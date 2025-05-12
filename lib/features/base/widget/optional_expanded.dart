import 'package:flutter/material.dart';

class OptionalExpanded extends StatelessWidget {
  const OptionalExpanded({
    super.key,
    required this.expandedEnabled,
    required this.child,
  });

  final bool expandedEnabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return expandedEnabled ? Expanded(child: child) : child;
  }
}