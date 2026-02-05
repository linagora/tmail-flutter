
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class DefaultCloseButtonWidget extends StatelessWidget {
  final String iconClose;
  final VoidCallback onTapActionCallback;
  final bool isAlignTopEnd;

  const DefaultCloseButtonWidget({
    super.key,
    required this.iconClose,
    required this.onTapActionCallback,
    this.isAlignTopEnd = true,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 4,
      end: isAlignTopEnd ? 4 : null,
      start: isAlignTopEnd ? 0 : 4,
      child: TMailButtonWidget.fromIcon(
        icon: iconClose,
        iconSize: 24,
        iconColor: AppColor.m3Tertiary,
        padding: const EdgeInsets.all(10),
        borderRadius: 24,
        backgroundColor: Colors.transparent,
        onTapActionCallback: onTapActionCallback,
      ),
    );
  }
}
