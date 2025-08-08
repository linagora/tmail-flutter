import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchLabelButtonWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final bool isActive;
  final String label;
  final VoidCallback onSwitchAction;
  final EdgeInsetsGeometry? padding;

  const SwitchLabelButtonWidget({
    super.key,
    required this.imagePaths,
    required this.isActive,
    required this.label,
    required this.onSwitchAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Row(
      children: [
        InkWell(
          onTap: onSwitchAction,
          child: SvgPicture.asset(
            isActive ? imagePaths.icSwitchOn : imagePaths.icSwitchOff,
            fit: BoxFit.fill,
            width: 52,
            height: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: ThemeUtils.textStyleBodyBody2(color: Colors.black),
          ),
        )
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
