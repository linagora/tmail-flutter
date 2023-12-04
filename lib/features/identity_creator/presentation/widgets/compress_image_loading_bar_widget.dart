import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';

class CompressImageLoadingBarWidget extends StatelessWidget {

  final bool isCompressing;
  final EdgeInsetsGeometry? padding;

  const CompressImageLoadingBarWidget({
    super.key,
    required this.isCompressing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompressing) {
      return CircleLoadingWidget(padding: padding);
    } else {
      return const SizedBox.shrink();
    }
  }
}