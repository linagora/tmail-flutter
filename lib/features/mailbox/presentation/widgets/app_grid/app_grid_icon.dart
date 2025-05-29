import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class AppGridIcon extends StatelessWidget {

  final String icon;
  final VoidCallback onTapAction;

  const AppGridIcon({
    super.key,
    required this.icon,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: icon,
      backgroundColor: Colors.transparent,
      iconSize: 24,
      iconColor: AppColor.blackAlpha40,
      padding: const EdgeInsets.all(8),
      onTapActionCallback: onTapAction,
    );
  }
}
