import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a `SliverAppBar` on material and a `CupertinoSliverNavigationBar`
/// on cupertino
class EnoughPlatformSliverAppBar extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool stretch;
  final List<Widget>? actions;
  final String? previousPageTitle;
  final Widget? flexibleSpace;
  final bool cupertinoTransitionBetweenRoutes;

  const EnoughPlatformSliverAppBar({
    Key? key,
    this.title,
    this.leading,
    this.floating = false,
    this.snap = false,
    this.pinned = false,
    this.stretch = false,
    this.actions,
    this.previousPageTitle,
    this.flexibleSpace,
    this.cupertinoTransitionBetweenRoutes = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => SliverAppBar(
        title: title,
        leading: leading,
        flexibleSpace: flexibleSpace,
        floating: floating,
        snap: snap,
        pinned: pinned,
        stretch: stretch,
        actions: actions,
      ),
      cupertino: (context, platform) {
        final actions = this.actions;
        final trailing = (actions == null || actions.isEmpty)
            ? null
            : (actions.length == 1)
                ? actions.first
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions,
                  );
        return CupertinoSliverNavigationBar(
          stretch: stretch,
          largeTitle: title,
          leading: leading,
          previousPageTitle: previousPageTitle,
          trailing: trailing,
          transitionBetweenRoutes: cupertinoTransitionBetweenRoutes,
        );
      },
    );
  }
}
