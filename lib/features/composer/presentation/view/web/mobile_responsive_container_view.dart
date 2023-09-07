import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/mobile_responsive_container_view_style.dart';

class MobileResponsiveContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;

  const MobileResponsiveContainerView({
    super.key,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MobileResponsiveContainerViewStyle.outSideBackgroundColor,
      body: LayoutBuilder(builder: (context, constraints) =>
        PointerInterceptor(
          child: childBuilder.call(context, constraints)
        )
      )
    );
  }
}