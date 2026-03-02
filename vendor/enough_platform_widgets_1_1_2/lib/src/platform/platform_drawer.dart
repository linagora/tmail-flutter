import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates a Drawer on material and a CupertinoPageScaffold on cupertiono
class PlatformDrawer extends StatelessWidget {
  final Widget child;
  const PlatformDrawer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Drawer(
        child: child,
      ),
      cupertino: (context, platform) => CupertinoPageScaffold(child: child),
    );
  }
}
