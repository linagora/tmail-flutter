
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CleanMessagesBanner extends StatelessWidget {
  final String message;
  final String positiveAction;
  final VoidCallback onPositiveAction;
  final EdgeInsetsGeometry? margin;

  const CleanMessagesBanner({
    super.key,
    required this.message,
    required this.positiveAction,
    required this.onPositiveAction,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.m3LayerDarkOutline.withOpacity(0.08),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      margin: margin,
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColor.steelGray400,
          ),
          children: [
            TextSpan(text: '$message '),
            TextSpan(
              text: positiveAction,
              style: ThemeUtils.textStyleInter700(
                color: AppColor.blue700,
                fontSize: 14,
              ),
              recognizer: TapGestureRecognizer()..onTap = onPositiveAction,
            ),
          ],
        ),
      ),
    );
  }
}
