
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class DefaultCloseButtonWidget extends StatelessWidget {
  final String iconClose;
  final VoidCallback onTapActionCallback;

  const DefaultCloseButtonWidget({
    super.key,
    required this.iconClose,
    required this.onTapActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 4,
      end: 4,
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
