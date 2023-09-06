import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/mobile_container_view_style.dart';

class MobileContainerView extends StatelessWidget {

  final Widget Function(BuildContext context, BoxConstraints constraints) childBuilder;

  const MobileContainerView({
    super.key,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MobileContainerViewStyle.outSideBackgroundColor,
      body: LayoutBuilder(builder: (context, constraints) =>
        PointerInterceptor(
          child: childBuilder.call(context, constraints)
        )
      )
    );
  }
}