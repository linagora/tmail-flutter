import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/tablet_responsive_container_view_style.dart';

class TabletResponsiveContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  TabletResponsiveContainerView({
    super.key,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TabletResponsiveContainerViewStyle.outSideBackgroundColor,
      body: Center(
        child: Card(
          elevation: TabletResponsiveContainerViewStyle.elevation,
          margin: TabletResponsiveContainerViewStyle.getMargin(context, _responsiveUtils),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(TabletResponsiveContainerViewStyle.radius))
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: TabletResponsiveContainerViewStyle.backgroundColor,
            width: TabletResponsiveContainerViewStyle.getWidth(context, _responsiveUtils),
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