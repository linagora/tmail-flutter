import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';

class AttachmentListActionButtonBuilder extends StatelessWidget {
  final String? name;
  final TextStyle? textStyle;
  final Color? bgColor;
  final Function? action;

  const AttachmentListActionButtonBuilder({
    super.key,
    this.name,
    this.textStyle,
    this.bgColor,
    this.action
  });

  @override
  Widget build(BuildContext context) {
    return buildButtonWrapText(
        name ?? '',
        radius: 10,
        height: 44,
        textStyle: textStyle,
        bgColor: bgColor,
        onTap: () => action?.call(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
