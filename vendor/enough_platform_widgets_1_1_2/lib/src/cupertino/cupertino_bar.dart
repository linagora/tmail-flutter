import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// A simple cupertino bar that either blurs the background or provides a translucent background
class CupertinoBar extends StatelessWidget {
  final Widget child;
  final bool blurBackground;
  final double backgroundOpacity;

  const CupertinoBar({
    Key? key,
    required this.child,
    this.blurBackground = false,
    this.backgroundOpacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = CupertinoTheme.of(context)
        .barBackgroundColor
        .withOpacity(backgroundOpacity);
    return blurBackground
        ? ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(color: color, child: child),
            ),
          )
        : Container(color: color, child: child);
  }
}
