import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/desktop_container_view_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/minimize_composer_widget.dart';

class DesktopContainerView extends StatelessWidget {

  final ScreenDisplayMode displayMode;
  final String emailSubject;
  final VoidCallback onCloseViewAction;
  final OnChangeDisplayModeAction onChangeDisplayModeAction;
  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  DesktopContainerView({
     super.key,
    required this.childBuilder,
    required this.displayMode,
    required this.emailSubject,
    required this.onCloseViewAction,
    required this.onChangeDisplayModeAction,
  });

  @override
  Widget build(BuildContext context) {
    if (displayMode == ScreenDisplayMode.minimize) {
      return PositionedDirectional(
        end: DesktopContainerViewStyle.margin,
        bottom: DesktopContainerViewStyle.margin,
        child: PointerInterceptor(
          child: MinimizeComposerWidget(
            emailSubject: emailSubject,
            onCloseViewAction: onCloseViewAction,
            onChangeDisplayModeAction: onChangeDisplayModeAction,
          ),
        )
      );
    } else if (displayMode == ScreenDisplayMode.normal) {
      final maxWidth = _responsiveUtils.getSizeScreenWidth(context) * 0.5;
      final maxHeight = _responsiveUtils.getSizeScreenHeight(context) * 0.75;

      return PositionedDirectional(
        end: DesktopContainerViewStyle.margin,
        bottom: DesktopContainerViewStyle.margin,
        child: Card(
          elevation: DesktopContainerViewStyle.elevation,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(DesktopContainerViewStyle.radius))
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: DesktopContainerViewStyle.backgroundColor,
            width: maxWidth,
            height: maxHeight,
            child: LayoutBuilder(builder: (context, constraints) =>
              PointerInterceptor(
                child: childBuilder.call(context, constraints)
              )
            )
          ),
        )
      );
    } else if (displayMode == ScreenDisplayMode.fullScreen) {
      final maxWidth = _responsiveUtils.getSizeScreenWidth(context) * 0.85;
      final maxHeight = _responsiveUtils.getSizeScreenHeight(context) * 0.9;

      return Scaffold(
        backgroundColor: DesktopContainerViewStyle.outSideBackgroundColor,
        body: Center(
          child: Card(
            elevation: DesktopContainerViewStyle.elevation,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(DesktopContainerViewStyle.radius))
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              color: DesktopContainerViewStyle.backgroundColor,
              width: maxWidth,
              height: maxHeight,
              child: LayoutBuilder(builder: (context, constraints) =>
                PointerInterceptor(
                  child: childBuilder.call(context, constraints)
                )
              )
            ),
          ),
        )
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}