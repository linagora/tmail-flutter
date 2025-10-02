import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class ShortcutKeyWidget extends StatelessWidget {
  final String label;

  const ShortcutKeyWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColor.blue100,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        border: Border.all(
          width: 1,
          color: AppColor.gray200,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black.withValues(alpha: 0.88),
            ),
      ),
    );
  }
}
