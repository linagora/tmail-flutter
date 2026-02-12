import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Provides a basis for any cupertino (iOS / macOS) or material (Android, web) app.
///
/// Adds the option to provide a bottom bar
class PlatformPageScaffold extends StatelessWidget {
  final Key? widgetKey;
  final Widget? body;
  final Color? backgroundColor;
  final PlatformAppBar? appBar;
  final Widget? bottomBar;
  final PlatformNavBar? bottomNavBar;
  final bool iosContentPadding;
  final bool iosContentPaddingBottom;
  final MaterialScaffoldData Function(BuildContext, PlatformTarget)? material;
  final CupertinoPageScaffoldData Function(BuildContext, PlatformTarget)?
      cupertino;

  const PlatformPageScaffold({
    Key? key,
    this.widgetKey,
    this.body,
    this.backgroundColor,
    this.appBar,
    this.bottomBar,
    this.bottomNavBar,
    this.iosContentPadding = false,
    this.iosContentPaddingBottom = false,
    this.material,
    this.cupertino,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      widgetKey: widgetKey,
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor,
      bottomNavBar: bottomNavBar,
      iosContentPadding: iosContentPadding,
      iosContentBottomPadding: iosContentPaddingBottom,
      material: _buildMaterial,
      cupertino: _buildCupertino,
    );
  }

  CupertinoPageScaffoldData _buildCupertino(
      BuildContext context, PlatformTarget platform) {
    final data = cupertino?.call(context, platform);
    final bbar = bottomBar;
    final content = data?.body ?? body;
    return CupertinoPageScaffoldData(
      backgroundColor: data?.backgroundColor,
      body: bbar == null
          ? content
          : CupertinoPageWithBar(
              child: content ?? Container(),
              bar: bbar,
            ),
      widgetKey: data?.widgetKey,
      navigationBar: data?.navigationBar,
      bottomTabBar: data?.bottomTabBar,
      resizeToAvoidBottomInset: data?.resizeToAvoidBottomInset,
      resizeToAvoidBottomInsetTab: data?.resizeToAvoidBottomInsetTab,
      backgroundColorTab: data?.backgroundColorTab,
      restorationIdTab: data?.restorationIdTab,
      controller: data?.controller,
    );
  }

  MaterialScaffoldData _buildMaterial(
      BuildContext context, PlatformTarget platform) {
    final data = material?.call(context, platform);
    return MaterialScaffoldData(
      // set bottom bar:
      bottomNavBar: data?.bottomNavBar ?? bottomBar,
      // copy other custom values:
      backgroundColor: data?.backgroundColor,
      body: data?.body,
      widgetKey: data?.widgetKey,
      appBar: data?.appBar,
      drawer: data?.drawer,
      endDrawer: data?.endDrawer,
      floatingActionButton: data?.floatingActionButton,
      floatingActionButtonAnimator: data?.floatingActionButtonAnimator,
      floatingActionButtonLocation: data?.floatingActionButtonLocation,
      persistentFooterButtons: data?.persistentFooterButtons,
      primary: data?.primary,
      bottomSheet: data?.bottomSheet,
      drawerDragStartBehavior: data?.drawerDragStartBehavior,
      drawerEdgeDragWidth: data?.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: data?.drawerEnableOpenDragGesture,
      drawerScrimColor: data?.drawerScrimColor,
      onDrawerChanged: data?.onDrawerChanged,
      endDrawerEnableOpenDragGesture: data?.endDrawerEnableOpenDragGesture,
      onEndDrawerChanged: data?.onEndDrawerChanged,
      extendBody: data?.extendBody,
      extendBodyBehindAppBar: data?.extendBodyBehindAppBar,
      resizeToAvoidBottomInset: data?.resizeToAvoidBottomInset,
      restorationId: data?.restorationId,
    );
  }
}
