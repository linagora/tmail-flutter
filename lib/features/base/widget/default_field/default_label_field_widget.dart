
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class DefaultLabelFieldWidget extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const DefaultLabelFieldWidget({
    super.key,
    required this.label,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Container(
      height: 38,
      width: width,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
