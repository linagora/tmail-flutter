import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

/// Provides a toolbar wrapper
class PlatformToolbar extends StatelessWidget {
  final List<Widget> children;
  const PlatformToolbar({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Material(
        elevation: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
      cupertino: (context, platform) => CupertinoToolbar(children: children),
    );
  }
}
