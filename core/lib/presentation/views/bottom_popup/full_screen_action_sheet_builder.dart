import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef OnCloseActionClick = Function();

class FullScreenActionSheetBuilder {
  final BuildContext context;
  final Widget child;

  final Widget? titleWidget;
  final Widget? cancelWidget;
  OnCloseActionClick? onCloseActionClick;

  FullScreenActionSheetBuilder({
    required this.context,
    required this.child,
    this.titleWidget,
    this.cancelWidget,
    this.onCloseActionClick,
  });

  Future show() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      backgroundColor: Colors.transparent,
      builder: (context) => PointerInterceptor(child: _buildBody(context)),
    );
  }

  double _getStatusBarHeight() => MediaQuery.of(context).viewPadding.top;

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: GestureDetector(
        onTap: () => {},
        child: Padding(
            padding: EdgeInsets.only(top: _getStatusBarHeight()),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(14),
                topLeft: Radius.circular(14),
              ),
              child: Scaffold(
                appBar: AppBar(
                  leading: SizedBox.shrink(),
                  title: titleWidget,
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                      child: cancelWidget,
                      onTapDown: (_) {
                        onCloseActionClick?.call();
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                body: child,
              ),
            )),
      ),
    );
  }
}
