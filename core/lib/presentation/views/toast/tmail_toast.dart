import 'dart:async';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/toast/toast_position.dart';
import 'package:flutter/material.dart';

class TMailToast {
  static showToast(
    String text,
    BuildContext context, {
    Duration? toastDuration,
    ToastPosition? toastPosition,
    Color? backgroundColor,
    TextStyle? textStyle,
    double toastBorderRadius = 10.0,
    Border? border,
    Widget? trailing,
    Widget? leading,
    double maxWidth = 424,
    EdgeInsets? padding,
    TextAlign? textAlign
  }) {
    ToastView.dismiss();
    ToastView.createView(
      text,
      context,
      toastPosition,
      backgroundColor,
      textStyle,
      toastBorderRadius,
      border,
      trailing,
      leading,
      maxWidth,
      padding,
      textAlign,
      toastDuration: toastDuration,
    );
  }
}

class ToastView {
  static final ToastView _instance = ToastView._internal();
  factory ToastView() => _instance;
  ToastView._internal();

  static OverlayState? overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void createView(
    String text,
    BuildContext context,
    ToastPosition? toastPosition,
    Color? backgroundColor,
    TextStyle? textStyle,
    double toastBorderRadius,
    Border? border,
    Widget? trailing,
    Widget? leading,
    double maxWidth,
    EdgeInsets? padding,
    TextAlign? textAlign,
    {Duration? toastDuration}
  ) async {
    overlayState = Overlay.of(context, rootOverlay: false);
    final Widget child = Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(toastBorderRadius),
            border: border,
            boxShadow: const [
              BoxShadow(
                color: AppColor.colorShadowLayerBottom,
                blurRadius: 24,
                offset: Offset.zero),
              BoxShadow(
                color: AppColor.colorShadowBgContentEmail,
                blurRadius: 2,
                offset: Offset.zero),
            ]
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: trailing == null && leading == null
            ? Text(
                text,
                softWrap: true,
                style: textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.normal
                ),
                textAlign: textAlign
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) leading,
                  if (trailing != null)
                    Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        text,
                        style: textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.normal
                        ),
                        textAlign: textAlign
                      )
                    ))
                  else
                    Container(
                      constraints: BoxConstraints(maxWidth: _getMaxWidthTitleByLeadingTrailingSize(
                        currentMaxWidth: maxWidth,
                        leading: leading
                      )),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        text,
                        style: textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.normal
                        ),
                        textAlign: textAlign
                      ),
                    ),
                  if (trailing != null) trailing
                ],
              ),
        ),
      ),
    );


    _overlayEntry = OverlayEntry(builder: (context) =>
      _showWidgetBasedOnPosition(
        toastDuration != null
          ? ToastCard(child, toastDuration)
          : child,
        toastPosition,
      )
    );

    _isVisible = true;
    overlayState!.insert(_overlayEntry!);
    if (toastDuration != null) {
      await Future.delayed(toastDuration);
      await dismiss();
    }
  }

  static double _getMaxWidthTitleByLeadingTrailingSize({
    required double currentMaxWidth,
    Widget? leading
  }) {
    return leading == null ? currentMaxWidth : currentMaxWidth - 100;
  }

  static Positioned _showWidgetBasedOnPosition(
    Widget child,
    ToastPosition? toastPosition
  ) {
    switch (toastPosition) {
      case ToastPosition.BOTTOM:
        return Positioned(bottom: 80, left: 18, right: 18, child: child);
      case ToastPosition.BOTTOM_LEFT:
        return Positioned(bottom: 80, left: 18, child: child);
      case ToastPosition.BOTTOM_RIGHT:
        return Positioned(bottom: 80, right: 18, child: child);
      case ToastPosition.CENTER:
        return Positioned(top: 60, bottom: 60, left: 18, right: 18, child: child);
      case ToastPosition.CENTER_LEFT:
        return Positioned(top: 60, bottom: 60, left: 18, child: child);
      case ToastPosition.CENTER_RIGHT:
        return Positioned(top: 60, bottom: 60, right: 18, child: child);
      case ToastPosition.TOP_LEFT:
        return Positioned(top: 110, left: 18, child: child);
      case ToastPosition.TOP_RIGHT:
        return Positioned(top: 110, right: 18, child: child);
      default:
        return Positioned(top: 110, left: 18, right: 18, child: child);
    }
  }

  static Future<void> dismiss() async {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

class ToastCard extends StatefulWidget {
  const ToastCard(
    this.child,
    this.duration,
    {
      Key? key,
      this.fadeDuration = 300
    }
  ) : super(key: key);

  final Widget child;
  final Duration duration;
  final int fadeDuration;

  @override
  ToastStateFulState createState() => ToastStateFulState();
}

class ToastStateFulState extends State<ToastCard>
    with SingleTickerProviderStateMixin {
  void showAnimation() {
    _animationController!.forward();
  }

  void hideAnimation() {
    _animationController!.reverse();
    _timer?.cancel();
  }

  AnimationController? _animationController;
  late Animation _fadeAnimation;

  Timer? _timer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fadeDuration),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
    super.initState();

    showAnimation();
    _timer = Timer(widget.duration, hideAnimation);
  }

  @override
  void deactivate() {
    _timer?.cancel();
    _animationController!.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fadeAnimation as Animation<double>,
    child: widget.child,
  );
}