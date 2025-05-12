import 'package:flutter/material.dart';

class OptionalScroll extends StatelessWidget {
  const OptionalScroll({
    super.key,
    required this.scrollEnabled,
    required this.child,
    this.scrollPhysics = const ClampingScrollPhysics(),
  });

  final bool scrollEnabled;
  final Widget child;
  final ScrollPhysics scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return scrollEnabled
      ? SingleChildScrollView(
          physics : scrollPhysics,
          child: child,
        )
      : child;
  }
}