import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

/// Shows a `BottomAppBar` on materal and a `CupertinoBar` on cupertino
class PlatformBottomBar extends StatelessWidget {
  final Widget child;
  final double materialElevation;
  final bool cupertinoBlurBackground;
  final double cupertinoBackgroundOpacity;
  const PlatformBottomBar(
      {Key? key,
      required this.child,
      this.materialElevation = 8.0,
      this.cupertinoBlurBackground = false,
      this.cupertinoBackgroundOpacity = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => BottomAppBar(
        child: child,
        elevation: materialElevation,
      ),
      cupertino: (context, platform) => CupertinoBar(
        child: child,
        blurBackground: cupertinoBlurBackground,
        backgroundOpacity: cupertinoBackgroundOpacity,
      ),
    );
  }
}
