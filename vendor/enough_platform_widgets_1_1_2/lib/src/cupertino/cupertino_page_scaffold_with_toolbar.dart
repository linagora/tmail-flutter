import 'package:flutter/cupertino.dart';

/// Provides a scaffold with the option to define a toolbar widget
class CupertinoPageScaffoldWithToolbar extends StatelessWidget {
  final Widget child;
  final ObstructingPreferredSizeWidget? navigationBar;
  final Color? backgroundColor;
  final Widget? toolbar;
  final bool blurToolbar;
  final bool resizeToAvoidBottomInset;

  const CupertinoPageScaffoldWithToolbar({
    Key? key,
    required this.child,
    this.navigationBar,
    this.backgroundColor,
    this.toolbar,
    this.resizeToAvoidBottomInset = true,
    this.blurToolbar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tbar = toolbar;
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: tbar == null
          ? child
          : Column(
              children: [
                Expanded(child: child),
                tbar,
              ],
            ),
    );
  }
}
