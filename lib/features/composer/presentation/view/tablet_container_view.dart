import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/tablet_container_view_style.dart';

class TabletContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  TabletContainerView({
    super.key,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TabletContainerViewStyle.outSideBackgroundColor,
      body: Center(
        child: Card(
          elevation: TabletContainerViewStyle.elevation,
          margin: TabletContainerViewStyle.getMargin(context, _responsiveUtils),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TabletContainerViewStyle.radius))
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: TabletContainerViewStyle.backgroundColor,
            width: TabletContainerViewStyle.getWidth(context, _responsiveUtils),
            child: LayoutBuilder(builder: (context, constraints) =>
              PointerInterceptor(
                child: childBuilder.call(context, constraints)
              )
            )
          ),
        ),
      )
    );
  }
}