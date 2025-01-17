
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PopupMenuOverlayWidget extends StatelessWidget {

  final List<Widget> listButtonAction;
  final Widget iconButton;
  final double? elevation;
  final double? borderRadius;
  final Color? backgroundColor;
  final CustomPopupMenuController? controller;
  final bool arrangeAsList;
  final PreferredPosition? position;
  final EdgeInsetsGeometry? padding;

  const PopupMenuOverlayWidget({
    Key? key,
    required this.iconButton,
    required this.listButtonAction,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.controller,
    this.position = PreferredPosition.bottom,
    this.arrangeAsList = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      controller: controller,
      menuBuilder: () {
        return Material(
          elevation: elevation ?? 10,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          color: backgroundColor ?? Colors.white,
          child: PointerInterceptor(
            child: Container(
              decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius ?? 12)),
              padding: padding,
              clipBehavior: Clip.antiAlias,
              child: arrangeAsList
                ? IntrinsicWidth(child: Column(children: listButtonAction))
                : Wrap(children: listButtonAction)
            ),
          ),
        );
      },
      pressType: PressType.singleClick,
      position: position,
      barrierColor: Colors.transparent,
      arrowSize: 0.0,
      verticalMargin: 8,
      child: iconButton,
    );
  }
}